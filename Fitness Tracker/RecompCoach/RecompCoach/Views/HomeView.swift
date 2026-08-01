//
//  HomeView.swift
//  RecompCoach
//
//  Dashboard home: a week day strip (today selected), a swipeable hero
//  carousel (Today's Workout, the time-based Next Meal, and today's Activity),
//  and quick stat chips pulled from the selected day's log.
//

import SwiftUI
import SwiftData
import UIKit

/// Navigation targets pushed from the dashboard.
enum HomeRoute: Hashable {
    case meal(MealDef, Date)
    case stat(StatKind)
}

struct HomeView: View {
    @Environment(\.modelContext) private var context
    @Environment(HealthKitManager.self) private var health
    @Environment(NotificationsManager.self) private var notifications
    @Environment(AppRouter.self) private var router
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]
    @Query private var mealLogs: [MealLog]
    @Query private var sessions: [WorkoutSession]

    /// Which page of the hero carousel (workout / meal / activity) is showing.
    @State private var heroPage = 0

    /// Shared with the header's "Today" calendar dropdown so both pickers
    /// (week strip + header calendar) stay in sync.
    private var selectedDate: Date { router.selectedDate }

    // Health values for a selected day that isn't today — fetched on demand
    // since Health retains this history indefinitely even though the app
    // only keeps a live "today" snapshot in HealthKitManager.
    @State private var historicalWeight: Double?
    @State private var historicalSteps: Int?
    @State private var historicalSleepNight: SleepNight?
    @State private var historicalBodyFat: Double?
    @State private var historicalLeanMass: Double?
    @State private var historicalStandHours: Int?
    @State private var historicalExerciseMinutes: Int?

    private var profile: UserProfile? { profiles.first }
    private var cal: Calendar { Calendar.current }
    private var isToday: Bool { cal.isDateInToday(selectedDate) }

    private var programDay: Int {
        guard let p = profile else { return 1 }
        return ProgramClock.dayNumber(start: p.startDate, on: selectedDate)
    }

    private var programWeek: Int {
        guard let p = profile else { return 1 }
        return ProgramClock.weekNumber(start: p.startDate, on: selectedDate)
    }

    private var selectedLog: DailyLog? {
        dailyLogs.first { cal.isDate($0.date, inSameDayAs: selectedDate) }
    }

    var body: some View {
        @Bindable var router = router
        return NavigationStack(path: $router.homePath) {
            ScrollView {
                VStack(spacing: 16) {
                    WeekStrip(selectedDate: $router.selectedDate)
                    if health.isAvailable && !health.isConnected {
                        connectHealthBanner
                    }
                    if !notifications.isAuthorized {
                        enableNotificationsBanner
                    }
                    heroCarousel
                    activityCard
                    statChips
                }
                .padding(16)
                .padding(.bottom, 110)
            }
            .scrollContentBackground(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .refreshable {
                if health.isConnected { await health.refreshSnapshot() }
            }
            .task(id: selectedDate) {
                guard health.isConnected else { return }
                if isToday {
                    await health.refreshSnapshot()
                } else {
                    await loadHistoricalHealth()
                }
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .meal(let meal, let day):
                    MealDetailView(meal: meal, day: day)
                case .stat(let kind):
                    StatDetailView(kind: kind, day: selectedDate)
                }
            }
        }
    }

    // MARK: - Hero "Daily Process" ring

    private var workoutLoggedForSelected: Bool {
        sessions.contains { cal.isDate($0.date, inSameDayAs: selectedDate) }
    }
    private var mealsLoggedCount: Int {
        mealLogs.filter { cal.isDate($0.date, inSameDayAs: selectedDate) }.count
    }

    /// Fraction of the day's core actions completed: daily log, scheduled workout
    /// (or rest), and meals logged (of 3).
    private var dailyCompletion: Double {
        var done = 0.0, total = 0.0
        total += 1; if selectedLog != nil { done += 1 }
        let scheduled = ProgramCatalog.scheduledWorkout(forProgramDay: programDay)
        total += 1
        if scheduled.workout == nil { done += 1 }               // rest day counts as met
        else if workoutLoggedForSelected { done += 1 }
        total += 1; done += min(1.0, Double(mealsLoggedCount) / 3.0)
        return total > 0 ? done / total : 0
    }

    private var heroCard: some View {
        let pct = Int((dailyCompletion * 100).rounded())
        let scheduled = ProgramCatalog.scheduledWorkout(forProgramDay: programDay)
        let workoutDone = scheduled.workout == nil || workoutLoggedForSelected
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "circle.hexagongrid.fill")
                        .font(.system(size: 15))
                        .foregroundStyle(Theme.ember)
                    Text(isToday ? "Daily Process" : "Day Process")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                }
                VStack(alignment: .leading, spacing: 8) {
                    heroStat(icon: "fork.knife", text: "\(min(mealsLoggedCount, 3))/3 meals logged")
                    heroStat(icon: workoutDone ? "checkmark.circle.fill" : "dumbbell",
                             text: scheduled.workout == nil ? "Rest / recovery day"
                                   : (workoutLoggedForSelected ? "Workout complete" : "Workout pending"))
                }
            }
            Spacer(minLength: 0)
            CircularRing(progress: dailyCompletion, lineWidth: 12) {
                VStack(spacing: 0) {
                    Text("\(pct)")
                        .font(Theme.pixel(34))
                        .foregroundStyle(Theme.chalk)
                    Text("%").font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
            .frame(width: 104, height: 104)
        }
        .padding(20)
        .background(Theme.heroGradient)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private func heroStat(icon: String, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundStyle(Theme.ember)
                .frame(width: 16)
            Text(text)
                .font(.system(size: 12.5))
                .foregroundStyle(Theme.chalkDim)
        }
    }

    // MARK: - Stat chips

    /// Weight/steps/sleep prefer a manual log entry, then fall back to Apple
    /// Health — today's live snapshot, or a historical query for other days
    /// (Health keeps this history even though the app doesn't). Knee is
    /// manual-only (subjective).
    private var weightValue: Double? { selectedLog?.weightLb ?? (isToday ? health.latestWeightLb : historicalWeight) }
    private var stepsValue: Int? { selectedLog?.steps ?? (isToday ? health.stepsToday : historicalSteps) }
    /// Apple doesn't expose its sleep score, so this is our stage-based estimate.
    private var sleepNight: SleepNight? { isToday ? health.lastNightSleep : historicalSleepNight }
    /// Health-only — no manual entry, so a synced smart scale (e.g. Wyze Scale)
    /// is the sole source.
    private var bodyFatValue: Double? { isToday ? health.latestBodyFatPercent : historicalBodyFat }
    /// Fat-free mass — the closest HealthKit proxy for "muscle mass", which
    /// has no HealthKit type of its own.
    private var leanMassValue: Double? { isToday ? health.latestLeanBodyMassLb : historicalLeanMass }
    private var standHoursValue: Int? { isToday ? health.standHoursToday : historicalStandHours }
    private var exerciseMinutesValue: Int? { isToday ? health.exerciseMinutesToday : historicalExerciseMinutes }

    /// Pull weight/steps/sleep for `selectedDate` from Health when it isn't today.
    private func loadHistoricalHealth() async {
        let target = cal.startOfDay(for: selectedDate)
        let daysAgo = cal.dateComponents([.day], from: target, to: cal.startOfDay(for: .now)).day ?? 0
        guard daysAgo >= 0 else {
            historicalWeight = nil; historicalSteps = nil
            historicalSleepNight = nil
            historicalBodyFat = nil
            historicalLeanMass = nil
            historicalStandHours = nil
            historicalExerciseMinutes = nil
            return
        }
        let days = daysAgo + 1
        async let steps = health.dailySteps(days: days)
        async let weights = health.dailyWeights(days: days)
        async let nights = health.sleepNights(days: days)
        async let bodyFats = health.dailyBodyFat(days: days)
        async let leanMasses = health.dailyLeanBodyMass(days: days)
        async let standHours = health.dailyStandHours(days: days)
        async let exerciseMinutes = health.dailyExerciseMinutes(days: days)
        let (s, w, n, bf, lm, sh, em) = await (steps, weights, nights, bodyFats, leanMasses, standHours, exerciseMinutes)
        historicalSteps = s.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalWeight = w.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalBodyFat = bf.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalLeanMass = lm.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalStandHours = sh.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalExerciseMinutes = em.first { cal.isDate($0.date, inSameDayAs: target) }?.value
        historicalSleepNight = n.first { cal.isDate($0.date, inSameDayAs: target) }
    }

    private var statChips: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                CompactStatChip(
                    icon: "scalemass", label: "Weight",
                    value: weightValue.map { trimDecimal($0) } ?? "—",
                    unit: "lb", accent: Theme.ember
                ) { router.homePath.append(HomeRoute.stat(.weight)) }
                CompactStatChip(
                    icon: "person.fill", label: "Body Fat",
                    value: bodyFatValue.map { trimDecimal($0) } ?? "—",
                    unit: "%", accent: Theme.rust
                ) { router.homePath.append(HomeRoute.stat(.bodyFat)) }
                CompactStatChip(
                    icon: "figure.strengthtraining.traditional", label: "Lean Mass",
                    value: leanMassValue.map { trimDecimal($0) } ?? "—",
                    unit: "lb", accent: Theme.emberDeep
                ) { router.homePath.append(HomeRoute.stat(.leanMass)) }
            }
            WaterTrackerCard(day: selectedDate, target: profile?.waterTargetL ?? 3.75)
            sleepScoreCard
        }
    }

    // MARK: - Sleep Score (duplicated from the Sleep trend page, purple-only, no chart)

    private var sleepScoreCard: some View {
        Button {
            router.homePath.append(HomeRoute.stat(.sleep))
        } label: {
            SectionCard(title: "Sleep Score", subtitle: "Estimated from Apple Watch stages") {
                if let night = sleepNight {
                    VStack(spacing: 16) {
                        HStack(spacing: 18) {
                            CircularRing(progress: Double(night.score) / 100, arcColor: Theme.violet) {
                                VStack(spacing: 0) {
                                    Text("\(night.score)")
                                        .font(Theme.pixel(30))
                                        .foregroundStyle(Theme.chalk)
                                    Text(sleepScoreLabel(night.score))
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(Theme.violet)
                                }
                            }
                            VStack(spacing: 8) {
                                sleepBreakdownRow("Duration", String(format: "%.1f h", night.totalHours))
                                sleepBreakdownRow("Deep", "\(Int((night.deepPct * 100).rounded()))%")
                                sleepBreakdownRow("REM", "\(Int((night.remPct * 100).rounded()))%")
                            }
                        }
                        Text("Apple's own Sleep Score isn't shared with third-party apps — this is an estimate from your sleep stages.")
                            .font(.system(size: 11))
                            .foregroundStyle(Theme.chalkDim)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                } else if !health.isConnected {
                    Text("Connect Apple Health to see your sleep score.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                } else {
                    Text("No staged sleep data from your Watch for this day.")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func sleepScoreLabel(_ s: Int) -> String {
        s >= 85 ? "HIGH" : s >= 70 ? "GOOD" : s >= 50 ? "FAIR" : "LOW"
    }

    private func sleepBreakdownRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Theme.chalkDim)
            Spacer()
            Text(value).font(Theme.mono(13, weight: .semibold)).foregroundStyle(Theme.chalk)
        }
    }

    // MARK: - Connect Apple Health

    private var connectHealthBanner: some View {
        Button {
            Task { await health.requestAuthorization() }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.rust)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Connect Apple Health")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Text("Auto-fill weight, steps, sleep, body fat, and nutrition synced from apps like MyFitnessPal and Wyze")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.chalkDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Enable Notifications

    private var enableNotificationsBanner: some View {
        Button {
            Task {
                let granted = await notifications.requestAuthorization()
                if granted, let p = profile {
                    notifications.scheduleProgramMilestones(startDate: p.startDate)
                    notifications.scheduleWorkoutDayReminders(startDate: p.startDate)
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.ember)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable Notifications")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Text("Workout reminders, PR alerts, deload framing, and weekly summaries")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.chalkDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
        .buttonStyle(.plain)
    }

    // MARK: - Hero carousel (workout / meal / activity)

    /// Target height for every page — cards size their own content to match.
    private let heroCardHeight: CGFloat = 280

    /// One page's width = the screen minus Home's 16pt padding on each side —
    /// a plain constant (matching `WeekStrip.stripWidth`'s approach) rather
    /// than a measured `GeometryReader` value.
    private var heroCardWidth: CGFloat { UIScreen.main.bounds.width - 32 }

    /// Live horizontal drag translation while paging between cards.
    @State private var heroDragOffset: CGFloat = 0
    /// True while the carousel is being dragged (and briefly after release) —
    /// gates the cards' own tap actions so a swipe that started or ended over
    /// a button doesn't also register as a tap into that button's destination.
    @State private var heroDragActive = false

    /// A hand-rolled drag/snap carousel — the same technique the week strip
    /// uses — rather than `TabView(.page)` or a paging `ScrollView`. Both of
    /// those reliably clip/shift a tall card's content on-device (reproduced
    /// with plain bundled images too), so a system paging container isn't
    /// safe here; a plain HStack + offset avoids that class of bug entirely.
    private var heroCarousel: some View {
        VStack(spacing: 10) {
            HStack(spacing: 0) {
                workoutCard.frame(width: heroCardWidth, height: heroCardHeight)
                mealCard.frame(width: heroCardWidth, height: heroCardHeight)
            }
            .offset(x: -CGFloat(heroPage) * heroCardWidth + heroDragOffset)
            .frame(width: heroCardWidth, height: heroCardHeight, alignment: .leading)
            .clipped()
            .contentShape(Rectangle())
            .simultaneousGesture(
                DragGesture(minimumDistance: 8)
                    .onChanged { value in
                        // Any real movement counts as a swipe-in-progress, even before
                        // we know if it's horizontal — set this first so a card's
                        // Button (which recognizes on release regardless of the
                        // simultaneous DragGesture) sees the guard before it fires.
                        heroDragActive = true
                        guard abs(value.translation.width) > abs(value.translation.height) else { return }
                        heroDragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let h = value.translation.width
                        let v = value.translation.height
                        // Keep the guard up briefly past release — the card's tap
                        // gesture resolves on this same touch-up, so clearing the
                        // flag synchronously here could still race it.
                        resetHeroDragActiveSoon()
                        guard abs(h) > abs(v) else {
                            withAnimation(.easeOut(duration: 0.2)) { heroDragOffset = 0 }
                            return
                        }
                        let predicted = value.predictedEndTranslation.width
                        var newPage = heroPage
                        if h < -heroCardWidth / 3 || predicted < -heroCardWidth / 2 {
                            newPage = min(heroPage + 1, 1)
                        } else if h > heroCardWidth / 3 || predicted > heroCardWidth / 2 {
                            newPage = max(heroPage - 1, 0)
                        }
                        withAnimation(.easeOut(duration: 0.25)) {
                            heroPage = newPage
                            heroDragOffset = 0
                        }
                    }
            )
            heroPageIndicator
        }
    }

    private func resetHeroDragActiveSoon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { heroDragActive = false }
    }

    /// Wraps a hero-card tap action so a swipe that passed over the card's
    /// button doesn't also fire that button's destination.
    private func heroTap(_ action: @escaping () -> Void) -> () -> Void {
        { if !heroDragActive { action() } }
    }

    /// A page-dot row of our own, sitting below the cards rather than the
    /// system page control's default overlay on top of the page content.
    private var heroPageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<2, id: \.self) { i in
                Capsule()
                    .fill(i == heroPage ? Theme.steel : Theme.chalkDim.opacity(0.4))
                    .frame(width: i == heroPage ? 16 : 6, height: 6)
                    .animation(.easeInOut(duration: 0.2), value: heroPage)
            }
        }
    }

    private var activityCard: some View {
        Button {
            router.homePath.append(HomeRoute.stat(.steps))
        } label: {
            ActivityCard(
                steps: stepsValue,
                standHours: standHoursValue,
                exerciseMinutes: exerciseMinutesValue
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Today's Workout

    private var workoutCard: some View {
        let scheduled = ProgramCatalog.scheduledWorkout(forProgramDay: programDay)
        return Group {
            if let type = scheduled.workout {
                let def = ProgramCatalog.workout(for: type, week: programWeek, track: profile?.specializationTrack ?? .armsShoulders)
                // A workout is "in progress" when a draft for this same session
                // exists and has at least one set logged. Resuming keeps it.
                let inProgress = router.draft?.type == type && router.draft?.anyLogged == true
                HeroActionCard(
                    imageName: "WorkoutHero",
                    eyebrow: isToday ? "Today's Workout" : "Scheduled Workout",
                    title: def.name,
                    subtitle: "\(def.exercises.count) exercises · ~\(def.exercises.count * 8) min",
                    buttonIcon: inProgress ? "arrow.clockwise" : "play.fill",
                    buttonLabel: inProgress ? "Resume Workout" : "Begin Workout",
                    cardAction: heroTap {
                        // Tap the card body → land on the exercise list.
                        router.pendingOpenFirstExercise = false
                        router.workoutPath = []
                        router.pendingWorkout = type
                        router.tab = .workout
                    },
                    action: heroTap {
                        // Begin → jump into the first exercise. Resume → return to
                        // wherever you left off.
                        router.pendingOpenFirstExercise = !inProgress
                        router.pendingWorkout = type
                        router.tab = .workout
                    }
                )
            } else {
                // Fills the full card slot directly (like `HeroActionCard`) rather
                // than aspect-fitting to the Figma frame's 556:420 ratio — that
                // extra `.aspectRatio`/`.frame(maxHeight: .infinity)` indirection
                // made the card render taller than its slot, so the carousel's own
                // rectangular clip sliced off the rounded bottom corners and bled
                // into the next card. The ratio difference (280 vs. 279.5pt tall) is imperceptible.
                RestDayCard(
                    imageURL: ImageProvider.restDayURL(),
                    eyebrow: isToday ? "Today" : "Scheduled",
                    title: "Rest / Soccer",
                    cardWidth: heroCardWidth,
                    cardHeight: heroCardHeight
                )
            }
        }
    }

    // MARK: - Next Meal

    private var mealCard: some View {
        let (meal, rolls) = mealFocus()
        let eyebrow = rolls ? "Tomorrow · \(meal.type.display)"
            : (isToday ? "Next Meal · \(meal.type.display)" : "\(meal.type.display)")
        let logged = isMealLogged(meal)
        let day = mealDay(rolls: rolls)
        return HeroActionCard(
            imageName: "MealHero",
            eyebrow: eyebrow,
            title: meal.name,
            subtitle: meal.macroLine,
            buttonIcon: logged ? "checkmark" : "fork.knife",
            buttonLabel: logged ? "Logged" : "Log or view recipe",
            buttonColor: logged ? Theme.moss : Theme.ember,
            action: heroTap { router.homePath.append(HomeRoute.meal(meal, day)) }
        )
    }

    private func mealFocus() -> (meal: MealDef, rolls: Bool) {
        if isToday {
            let r = MealCatalog.focusMeal(forProgramDay: programDay)
            return (r.meal, r.rollsToTomorrow)
        } else {
            // Non-today: show that day's breakfast as the entry point to its plan.
            return (MealCatalog.day(forProgramDay: programDay).breakfast, false)
        }
    }

    private func mealDay(rolls: Bool) -> Date {
        rolls ? cal.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate : selectedDate
    }

    private func isMealLogged(_ meal: MealDef) -> Bool {
        let day = cal.startOfDay(for: selectedDate)
        return mealLogs.contains { $0.mealId == meal.id && cal.isDate($0.date, inSameDayAs: day) }
    }
}

// MARK: - Week strip

/// Horizontal Mon–Sun strip for the week containing `selectedDate`. Today is
/// marked; the selected day is filled.
struct WeekStrip: View {
    @Binding var selectedDate: Date

    /// The day centered in the middle of the 7-cell row — independent of
    /// `selectedDate` while swiping (so browsing another week doesn't change
    /// what Home's chips/cards show until you actually tap a day), but kept in
    /// sync with it otherwise so the selected day always sits in the middle.
    @State private var displayedCenter: Date
    /// Live horizontal drag translation — the carousel tracks this 1:1 while
    /// dragging, so it moves with the finger instead of only reacting on release.
    @State private var dragOffset: CGFloat = 0
    /// True while the strip is being dragged (and briefly after release) —
    /// gates day-cell taps so a swipe release doesn't also select that day.
    @State private var dragActive = false

    private var cal: Calendar { Calendar.current }

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
        self._displayedCenter = State(initialValue: Calendar.current.startOfDay(for: selectedDate.wrappedValue))
    }

    /// One page's width = the screen minus Home's 16pt padding on each side.
    /// A plain constant (not a measured GeometryReader value) so the 3-page
    /// carousel below always has a width to lay out against immediately.
    private var stripWidth: CGFloat { UIScreen.main.bounds.width - 32 }

    /// The 7 days centered on `displayedCenter` (3 before, 3 after), shifted a
    /// further `weekOffset * 7` days for the adjacent swipe pages.
    private func days(weekOffset: Int) -> [Date] {
        let center = cal.date(byAdding: .day, value: weekOffset * 7, to: displayedCenter) ?? displayedCenter
        return (-3...3).compactMap { cal.date(byAdding: .day, value: $0, to: center) }
    }

    var body: some View {
        HStack(spacing: 0) {
            weekRow(days(weekOffset: -1)).frame(width: stripWidth)
            weekRow(days(weekOffset: 0)).frame(width: stripWidth)
            weekRow(days(weekOffset: 1)).frame(width: stripWidth)
        }
        .offset(x: -stripWidth + dragOffset)
        .frame(width: stripWidth, alignment: .leading)
        .clipped()
        .contentShape(Rectangle())
        // Swipe left/right to page a week at a time, tracking the finger live
        // while dragging; `.simultaneousGesture` so it doesn't steal the
        // vertical scroll on Home.
        .simultaneousGesture(
            DragGesture(minimumDistance: 8)
                .onChanged { value in
                    // Set before the direction guard so a day-cell Button (which
                    // recognizes its own tap on release regardless of this
                    // simultaneous DragGesture) sees the flag before it fires.
                    dragActive = true
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    dragOffset = max(-stripWidth, min(stripWidth, value.translation.width))
                }
                .onEnded { value in
                    let h = value.translation.width
                    let v = value.translation.height
                    // Keep the guard up briefly past release, since the day-cell's
                    // tap gesture resolves on this same touch-up.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { dragActive = false }
                    guard abs(h) > abs(v) else {
                        withAnimation(.easeOut(duration: 0.2)) { dragOffset = 0 }
                        return
                    }
                    let predicted = value.predictedEndTranslation.width
                    let commitNext = h < -stripWidth / 3 || predicted < -stripWidth / 2
                    let commitPrev = h > stripWidth / 3 || predicted > stripWidth / 2
                    if commitNext {
                        page(weeks: 1)
                    } else if commitPrev {
                        page(weeks: -1)
                    } else {
                        withAnimation(.easeOut(duration: 0.2)) { dragOffset = 0 }
                    }
                }
        )
        // If selectedDate changes from outside (header calendar dropdown,
        // "Jump to Today"), re-center the strip on that day.
        .onChange(of: selectedDate) { _, newValue in
            let newCenter = cal.startOfDay(for: newValue)
            if newCenter != displayedCenter {
                displayedCenter = newCenter
            }
        }
    }

    /// Finish the drag by sliding fully to the next/previous page, then swap
    /// the displayed week and reset the offset in one unanimated step — the
    /// content at that scroll position is identical before/after the swap,
    /// so the reset itself isn't visible. `selectedDate` is untouched.
    private func page(weeks: Int) {
        withAnimation(.easeOut(duration: 0.22), completionCriteria: .logicallyComplete) {
            dragOffset = CGFloat(-weeks) * stripWidth
        } completion: {
            displayedCenter = cal.date(byAdding: .day, value: weeks * 7, to: displayedCenter) ?? displayedCenter
            dragOffset = 0
        }
    }

    private func weekRow(_ days: [Date]) -> some View {
        HStack(spacing: 6) {
            ForEach(days, id: \.self) { day in
                dayCell(day)
            }
        }
    }

    private func dayCell(_ day: Date) -> some View {
        let isSelected = cal.isDate(day, inSameDayAs: selectedDate)
        let isToday = cal.isDateInToday(day)
        return Button {
            guard !dragActive else { return }
            withAnimation(.easeInOut(duration: 0.15)) {
                let day = cal.startOfDay(for: day)
                selectedDate = day
                displayedCenter = day
            }
        } label: {
            VStack(spacing: 6) {
                Text(day, format: .dateTime.weekday(.abbreviated))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(isSelected ? Color(hex: 0x151515) : Theme.chalkDim)
                Text(day, format: .dateTime.day())
                    .font(Theme.pixel(20))
                    .foregroundStyle(isSelected ? Color(hex: 0x151515) : Theme.chalk)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? Theme.steel : Theme.iron)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.fieldRadius)
                    .stroke(isToday && !isSelected ? Theme.steel : Theme.hairline,
                            lineWidth: isToday && !isSelected ? 1.5 : 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stat chip

/// A dashboard stat tile: icon, then a large number, then the label, all
/// stacked and centered. Used for every Home stat chip (Weight / Body Fat /
/// Lean Mass in a 3-across row, Sleep / Water in a 2-across row).
struct CompactStatChip: View {
    let icon: String
    let label: String
    let value: String
    let unit: String
    var accent: Color = Theme.chalk
    /// Keep the icon in its accent color even with nothing logged yet — for
    /// icons like the water drop that are recognizable by color.
    var alwaysColoredIcon: Bool = false
    let action: () -> Void

    private var isEmpty: Bool { value == "—" }

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 15))
                    .foregroundStyle(isEmpty && !alwaysColoredIcon ? Theme.chalkDim : accent)
                if isEmpty {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(accent.opacity(0.85))
                        .padding(.vertical, 6)
                } else {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(value)
                            .font(Theme.pixel(24))
                            .foregroundStyle(Theme.chalk)
                        Text(unit)
                            .font(.system(size: 10))
                            .foregroundStyle(Theme.chalkDim)
                    }
                }
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 6)
            .background(Theme.iron)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hero action card

/// A large dashboard hero card: a fixed, bundled photo with a bottom-anchored
/// scrim, a white eyebrow pill, a title/subtitle overlaid, and a full-width
/// primary button that drills into a detail screen. Used by both the "Today's
/// Workout" and "Next Meal" cards on Home.
struct HeroActionCard: View {
    /// A bundled asset-catalog image (e.g. "WorkoutHero").
    var imageName: String? = nil
    let eyebrow: String
    let title: String
    let subtitle: String
    var imageHeight: CGFloat = 200
    var buttonIcon: String
    var buttonLabel: String
    var buttonColor: Color = Theme.ember
    /// Optional tap on the photo/body itself (distinct from the primary button).
    var cardAction: (() -> Void)? = nil
    let action: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if let cardAction {
                Button(action: cardAction) {
                    imageHeader.contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            } else {
                imageHeader.allowsHitTesting(false)
            }
            Button(action: action) {
                HStack(spacing: 8) {
                    Image(systemName: buttonIcon)
                        .font(.system(size: 14, weight: .bold))
                    Text(buttonLabel)
                        .font(Theme.display(16, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(buttonColor)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
            }
            .buttonStyle(.plain)
            .padding(14)
        }
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    @ViewBuilder private var photo: some View {
        if let imageName {
            Image(imageName).resizable().scaledToFill()
        } else {
            Theme.heroGradient
        }
    }

    /// Photo with a scrim that is transparent up top and reaches full
    /// black at the very bottom edge, so the title reads cleanly.
    private var imageHeader: some View {
        photo
            .frame(height: imageHeight)
            .frame(maxWidth: .infinity)
            .clipped()
            .overlay(
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: .black.opacity(0.15), location: 0.45),
                        .init(color: .black.opacity(0.60), location: 0.78),
                        .init(color: .black.opacity(0.92), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(alignment: .topLeading) {
                Text(eyebrow)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(Capsule())
                    .padding(12)
            }
            .overlay(alignment: .bottomLeading) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(Theme.display(24, weight: .bold))
                        .foregroundStyle(.white)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(subtitle)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundStyle(.white.opacity(0.9))
                }
                .shadow(color: .black.opacity(0.6), radius: 4, y: 1)
                .padding(16)
            }
    }
}

// MARK: - Rest day card

/// A full-bleed photo card with no footer button — the Figma "recovery card"
/// layout (node 3:21). Both `cardWidth` and `cardHeight` are concrete literal
/// values (matching the hero carousel's own cell size) rather than flexible
/// `.infinity`/Spacer-driven sizing: inside the carousel's offset-based
/// paging, any flexible negotiation here (leading-aligned `.frame(maxWidth:
/// .infinity)`, `.overlay(alignment:)`, or a `Spacer`-stretched VStack) either
/// clipped the pill/title on the left edge, or rendered the card taller than
/// its slot so the carousel's own rectangular clip sliced off the rounded
/// bottom corners and bled into the next card. A fully fixed frame sidesteps
/// both by giving the layout nothing left to negotiate.
struct RestDayCard: View {
    let imageURL: URL?
    let eyebrow: String
    let title: String
    var cardWidth: CGFloat
    var cardHeight: CGFloat

    var body: some View {
        ZStack(alignment: .top) {
            Group {
                if let imageURL {
                    RemoteImageView(url: imageURL, icon: "photo", cornerRadius: 0, bordered: false)
                } else {
                    Theme.heroGradient
                }
            }
            LinearGradient(
                stops: [
                    .init(color: .clear, location: 0.0),
                    .init(color: .clear, location: 0.42),
                    .init(color: .black, location: 1.0)
                ],
                startPoint: .top, endPoint: .bottom
            )
            VStack(alignment: .leading, spacing: 0) {
                Text(eyebrow)
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(.black)
                    .padding(.vertical, 5)
                    .padding(.horizontal, 10)
                    .background(.white)
                    .clipShape(Capsule())
                    .padding(12)
                Spacer(minLength: 0)
                Text(title)
                    .font(Theme.display(24, weight: .bold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.6), radius: 4, y: 1)
                    .padding(16)
            }
            .frame(width: cardWidth, height: cardHeight, alignment: .leading)
        }
        .frame(width: cardWidth, height: cardHeight)
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
    }
}

// MARK: - Activity card

/// Today's steps, Stand hours, and Exercise minutes — Apple's Move-adjacent
/// activity rings (minus Move itself, which duplicates active-energy already
/// shown elsewhere), all read from Health. Shares `HeroActionCard`'s shape (a
/// 200pt header plus a footer button) so it sits flush in the hero carousel.
struct ActivityCard: View {
    let steps: Int?
    let standHours: Int?
    let exerciseMinutes: Int?

    /// Standard daily targets (Apple Watch's own Stand/Exercise ring goals;
    /// 10k is the common step-count benchmark) — the app has no user-set
    /// activity targets of its own yet.
    private let stepGoal = 10_000
    private let standGoal = 12
    private let exerciseGoal = 30

    private var stepsProgress: Double {
        min(1, Double(steps ?? 0) / Double(stepGoal))
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.steel)
                    Text("Activity")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Spacer(minLength: 0)
                }
                ActivityBar(label: "Stand", value: standHours, target: standGoal, unit: "hrs", color: Theme.moss)
                ActivityBar(label: "Exercise", value: exerciseMinutes, target: exerciseGoal, unit: "min", color: Theme.ember)
            }
            CircularRing(progress: stepsProgress, arcColor: Theme.steel) {
                VStack(spacing: 0) {
                    Text(steps?.formatted() ?? "—")
                        .font(Theme.pixel(26))
                        .foregroundStyle(Theme.chalk)
                    Text("/ \(stepGoal.formatted())")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                    Text("steps")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
        }
        .padding(18)
        .background(Theme.heroGradient)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

/// A labelled activity progress bar (e.g. stand hours, exercise minutes)
/// against a fixed daily goal — mirrors `MacroBar`'s look for an optional value.
private struct ActivityBar: View {
    let label: String
    let value: Int?
    let target: Int
    let unit: String
    var color: Color = Theme.ember

    private var frac: Double {
        guard let value, target > 0 else { return 0 }
        return min(1, Double(value) / Double(target))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.chalkDim)
                Spacer()
                Text("\(value.map(String.init) ?? "—") / \(target)\(unit)")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalk)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule().fill(color).frame(width: max(0, geo.size.width * frac))
                }
            }
            .frame(height: 6)
        }
    }
}

