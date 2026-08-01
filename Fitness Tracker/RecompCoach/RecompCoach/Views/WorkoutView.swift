//
//  WorkoutView.swift
//  RecompCoach
//
//  The guided workout logger (tab 2). Shows the current session's exercises as
//  tappable chips; tapping one opens a one-set-at-a-time logger (weight + reps
//  tickers). "Next set" walks the sets; the last set finishes the exercise and
//  auto-advances to the next one. "Finish workout" persists the whole session.
//

import SwiftUI
import SwiftData

/// Navigation targets pushed from the Workout tab.
enum WorkoutRoute: Hashable {
    case exercise(Int)
    case fullProgram
}

// MARK: - Draft state

/// One editable set in the guided logger.
struct DraftSet: Identifiable {
    let id = UUID()
    var weight: String = ""
    var reps: String = ""
    var hold: String = ""
}

/// In-progress workout kept in memory until the user taps Finish.
@Observable final class WorkoutDraft {
    var type: WorkoutType
    /// Program week the draft was started in — pins the exercise content so a
    /// session begun in one phase doesn't shift mid-workout across a boundary.
    var week: Int
    var track: SpecializationTrack
    var setsByExercise: [String: [DraftSet]] = [:]
    var completed: Set<String> = []
    /// Exercises swapped in via the library, keyed by the *original* catalog
    /// exercise's id at that slot (stable across repeated swaps). Session-only
    /// — doesn't change the underlying program content.
    var substitutions: [String: ExerciseDef] = [:]

    init(type: WorkoutType, week: Int, track: SpecializationTrack = .armsShoulders) {
        self.type = type
        self.week = week
        self.track = track
        seed()
    }

    var exercises: [ExerciseDef] {
        ProgramCatalog.workout(for: type, week: week, track: track).exercises.map { substitutions[$0.id] ?? $0 }
    }

    /// Swaps `newExercise` in for the exercise originally at this slot. Resets
    /// that slot's logged sets since it's now a different movement.
    func swapExercise(originalId: String, for newExercise: ExerciseDef) {
        substitutions[originalId] = newExercise
        setsByExercise[newExercise.id] = (0..<WorkoutDraft.plannedSets(newExercise)).map { _ in DraftSet() }
        completed.remove(originalId)
        completed.remove(newExercise.id)
    }

    private func seed() {
        setsByExercise = [:]
        completed = []
        for ex in exercises {
            setsByExercise[ex.id] = (0..<WorkoutDraft.plannedSets(ex)).map { _ in DraftSet() }
        }
    }

    /// Number of sets prescribed, parsed from a "N × …" prescription (default 3).
    static func plannedSets(_ ex: ExerciseDef) -> Int {
        let s = ex.prescription
        if let idx = s.firstIndex(where: { $0 == "×" || $0 == "x" || $0 == "X" }) {
            let prefix = s[s.startIndex..<idx].trimmingCharacters(in: .whitespaces)
            if let n = Int(prefix) { return min(max(n, 1), 10) }
        }
        return 3
    }

    func sets(for id: String) -> [DraftSet] { setsByExercise[id] ?? [] }

    func filledCount(_ id: String) -> Int {
        sets(for: id).filter { !$0.weight.isEmpty || !$0.reps.isEmpty || !$0.hold.isEmpty }.count
    }

    var anyLogged: Bool {
        exercises.contains { completed.contains($0.id) || filledCount($0.id) > 0 }
    }
}

// MARK: - Workout tab

struct WorkoutView: View {
    @Environment(\.modelContext) private var context
    @Environment(AppRouter.self) private var router
    @Query private var profiles: [UserProfile]

    @State private var toast: String?
    @State private var programCardExpanded = false
    @State private var showLibrary = false

    private var profile: UserProfile? { profiles.first }
    private var cal: Calendar { Calendar.current }

    private var currentWeek: Int {
        guard let p = profile else { return 1 }
        return ProgramClock.weekNumber(start: p.startDate)
    }

    private var currentTrack: SpecializationTrack {
        profile?.specializationTrack ?? .armsShoulders
    }

    private var currentPhase: PhaseDef { ProgramCatalog.phase(forWeek: currentWeek) }

    /// Position within the current phase (e.g. week 1 of a 4-week phase),
    /// rather than the week's position across the full 52-week program.
    private var weekInPhase: Int { currentWeek - currentPhase.weekStart + 1 }
    private var phaseLength: Int { currentPhase.weekEnd - currentPhase.weekStart + 1 }

    // MARK: The selected day (shared with Home's calendar picker)

    private var selectedDate: Date { router.selectedDate }
    private var isSelectedToday: Bool { cal.isDateInToday(selectedDate) }

    private var selectedWeek: Int {
        guard let p = profile else { return 1 }
        return ProgramClock.weekNumber(start: p.startDate, on: selectedDate)
    }

    private var selectedScheduled: (workout: WorkoutType?, note: String?) {
        guard let p = profile else { return (nil, nil) }
        let day = ProgramClock.dayNumber(start: p.startDate, on: selectedDate)
        return ProgramCatalog.scheduledWorkout(forProgramDay: day)
    }

    /// The next day (after the selected one) with a scheduled workout —
    /// shown on a rest day so there's always something to look ahead to.
    private var nextScheduledWorkout: (date: Date, type: WorkoutType)? {
        guard let p = profile else { return nil }
        let start = cal.startOfDay(for: selectedDate)
        for offset in 1...8 {
            guard let d = cal.date(byAdding: .day, value: offset, to: start) else { continue }
            let day = ProgramClock.dayNumber(start: p.startDate, on: d)
            if let type = ProgramCatalog.scheduledWorkout(forProgramDay: day).workout {
                return (d, type)
            }
        }
        return nil
    }

    var body: some View {
        content
            .onAppear(perform: setup)
            .onChange(of: router.selectedDate, setup)
            .onChange(of: router.pendingWorkout) { _, new in
                if let new { startWorkout(new) }
            }
    }

    private var content: some View {
        @Bindable var router = router
        return NavigationStack(path: $router.workoutPath) {
            ScrollView {
                VStack(spacing: 16) {
                    programCard
                    if isRestDay { noWorkoutBanner }
                    mainSection
                }
                .padding(16)
                .padding(.bottom, 110)
            }
            .scrollContentBackground(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .blurredWhenPresenting(showLibrary)
            .sheet(isPresented: $showLibrary) { ExerciseLibrarySheet() }
            .navigationDestination(for: WorkoutRoute.self) { route in
                switch route {
                case .exercise(let index):
                    if let draft = router.draft {
                        ExerciseLogView(
                            exercise: draft.exercises[index],
                            position: "\(index + 1) of \(draft.exercises.count)",
                            isLastExercise: index + 1 >= draft.exercises.count,
                            draft: draft,
                            onDone: { goToNext(after: index, markDone: true) },
                            onSkip: { goToNext(after: index, markDone: false) }
                        )
                    }
                case .fullProgram:
                    FullProgramView(currentWeek: currentWeek)
                }
            }
            .overlay(alignment: .bottom) { ToastView(text: toast) }
        }
    }

    /// True when the selected day has nothing scheduled (today or otherwise) —
    /// i.e. neither the interactive logger nor the read-only preview applies.
    private var isRestDay: Bool {
        if isSelectedToday, router.draft != nil { return false }
        return selectedScheduled.workout == nil
    }

    /// Today with a scheduled session → the interactive guided logger. A
    /// different day (or today, previewed before starting) → that day's
    /// exercises read-only. No workout scheduled at all → the rest-day state.
    @ViewBuilder private var mainSection: some View {
        if isSelectedToday, let draft = router.draft {
            headerBlock(draft)
            exerciseList(draft)
            finishButton(draft)
        } else if let type = selectedScheduled.workout {
            previewHeaderBlock(type: type)
            previewExerciseList(type: type)
        } else {
            noWorkoutScheduledSection
        }
    }

    // MARK: Setup

    /// Seed today's draft the first time the tab is shown, but only when today
    /// actually has a scheduled session — a rest day stays empty rather than
    /// falling back to some other workout. If a draft already exists (the user
    /// is mid-workout and just tabbed away and back), leave it untouched.
    private func setup() {
        if let pending = router.pendingWorkout {
            startWorkout(pending)
        } else if router.draft == nil, isSelectedToday, let type = selectedScheduled.workout {
            router.draft = WorkoutDraft(type: type, week: selectedWeek, track: currentTrack)
        }
    }

    /// Begin (or re-open) a session. Only rebuilds the draft when the requested
    /// type differs, so re-tapping "Begin Workout" for the same session keeps
    /// what's already logged.
    private func startWorkout(_ type: WorkoutType) {
        if router.draft?.type != type {
            router.draft = WorkoutDraft(type: type, week: currentWeek, track: currentTrack)
            router.workoutPath = []
        }
        // "Begin Workout" drops straight into the first exercise; the card body
        // (flag off) leaves you on the exercise list.
        if router.pendingOpenFirstExercise {
            router.workoutPath = [.exercise(0)]
        }
        router.pendingOpenFirstExercise = false
        router.pendingWorkout = nil
    }

    // MARK: Program (current phase + Phase 5+ track picker) — accordion

    private var programCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) { programCardExpanded.toggle() }
            } label: {
                HStack(spacing: 14) {
                    CircularRing(
                        progress: Double(weekInPhase) / Double(phaseLength),
                        diameter: 76, lineWidth: 6, arcColor: Theme.ember
                    ) {
                        VStack(spacing: 0) {
                            Text("\(weekInPhase)")
                                .font(Theme.pixel(24))
                                .foregroundStyle(Theme.chalk)
                            Text("/\(phaseLength)")
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(Theme.chalkDim)
                        }
                    }
                    VStack(alignment: .leading, spacing: 3) {
                        Text(currentPhase.name).displayHeading()
                            .foregroundStyle(Theme.chalk)
                        Text("Phase weeks \(currentPhase.weekStart)–\(currentPhase.weekEnd)")
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.chalkDim)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                        .rotationEffect(.degrees(programCardExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)

            if programCardExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(currentPhase.goals, id: \.self) { goal in
                        HStack(alignment: .top, spacing: 8) {
                            Circle().fill(Theme.ember).frame(width: 5, height: 5).padding(.top, 6)
                            Text(goal)
                                .font(.system(size: 12.5))
                                .foregroundStyle(Theme.chalkDim)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    if currentWeek >= ProgramCatalog.phase5.weekStart {
                        Divider().overlay(Theme.hairline).padding(.vertical, 2)
                        Text("Specialization track")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(0.3)
                            .foregroundStyle(Theme.chalk)
                        trackPicker
                    }
                    NavigationLink(value: WorkoutRoute.fullProgram) {
                        HStack(spacing: 6) {
                            Text("Full program")
                            Image(systemName: "chevron.right")
                                .font(.system(size: 12, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(GhostButtonStyle())
                    .padding(.top, 2)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var trackPicker: some View {
        Menu {
            Picker("Track", selection: Binding(
                get: { profile?.specializationTrack ?? .armsShoulders },
                set: { newValue in
                    profile?.specializationTrack = newValue
                    try? context.save()
                }
            )) {
                ForEach(SpecializationTrack.allCases) { Text($0.label).tag($0) }
            }
        } label: {
            HStack(spacing: 6) {
                VStack(alignment: .leading, spacing: 2) {
                    Text((profile?.specializationTrack ?? .armsShoulders).label)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.chalk)
                    Text((profile?.specializationTrack ?? .armsShoulders).summary)
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.chalkDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 11)
            .frame(maxWidth: .infinity)
            .background(Theme.iron2)
            .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.fieldRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
        }
    }

    // MARK: Header (the day's session — no picker)

    private func headerBlock(_ draft: WorkoutDraft) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(draft.type.displayName)
                    .font(Theme.display(26, weight: .bold))
                    .foregroundStyle(Theme.chalk)
                Text(selectedDate, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.chalkDim)
            }
            Text("Tap an exercise to log your sets")
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Exercise chips

    private func exerciseList(_ draft: WorkoutDraft) -> some View {
        VStack(spacing: 10) {
            ForEach(Array(draft.exercises.enumerated()), id: \.element.id) { index, ex in
                NavigationLink(value: WorkoutRoute.exercise(index)) {
                    ExerciseChip(exercise: ex, draft: draft)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func finishButton(_ draft: WorkoutDraft) -> some View {
        VStack(spacing: 10) {
            Button { finish(draft) } label: {
                Text("Finish workout")
            }
            .buttonStyle(SteelButtonStyle())
            .opacity(draft.anyLogged ? 1 : 0.45)
            .disabled(!draft.anyLogged)

            Button { showLibrary = true } label: {
                Text("Exercise Library")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GhostButtonStyle())
        }
        .padding(.top, 4)
    }

    // MARK: Preview (a scheduled day that isn't today — read-only)

    private func previewHeaderBlock(type: WorkoutType) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(type.displayName)
                    .font(Theme.display(26, weight: .bold))
                    .foregroundStyle(Theme.chalk)
                Text(selectedDate, format: .dateTime.month(.abbreviated).day())
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.chalkDim)
            }
            Text("Scheduled — switch to today to log sets")
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func previewExerciseList(type: WorkoutType) -> some View {
        let def = ProgramCatalog.workout(for: type, week: selectedWeek, track: currentTrack)
        return VStack(spacing: 10) {
            ForEach(def.exercises) { ex in
                PreviewExerciseRow(exercise: ex)
            }
        }
    }

    // MARK: Rest day (nothing scheduled for the selected day)

    private var noWorkoutBanner: some View {
        VStack(spacing: 14) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 44))
                .foregroundStyle(Theme.chalkDim)
            Text(isSelectedToday ? "No workout scheduled today" : "No workout scheduled for this day")
                .font(Theme.display(21, weight: .bold))
                .foregroundStyle(Theme.chalk)
                .multilineTextAlignment(.center)
            Text("Take the rest, or get a head start on what's next below.")
                .font(.system(size: 13.5))
                .foregroundStyle(Theme.chalkDim)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 36)
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var noWorkoutScheduledSection: some View {
        VStack(spacing: 16) {
            if let next = nextScheduledWorkout {
                nextWorkoutTile(next)
            }

            Button {
                showLibrary = true
            } label: {
                Text("View Exercise Library")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
                    .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
                    .background(Theme.iron2)
                    .overlay(
                        RoundedRectangle(cornerRadius: Theme.fieldRadius)
                            .stroke(Theme.hairline, lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
            }
            .buttonStyle(.plain)
        }
    }

    private func nextWorkoutTile(_ next: (date: Date, type: WorkoutType)) -> some View {
        HStack(spacing: 12) {
            (
                Text("Next up ")
                    .foregroundStyle(Theme.chalkDim)
                + Text(next.type.displayName)
                    .foregroundStyle(Theme.chalk)
                    .fontWeight(.semibold)
                + Text(" on \(next.date.formatted(.dateTime.month(.wide).day()))")
                    .foregroundStyle(Theme.chalkDim)
            )
            .font(.system(size: 14))
            .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 8)
            Button {
                router.selectedDate = cal.startOfDay(for: next.date)
            } label: {
                Text("Preview")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.ember)
            }
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    // MARK: Flow

    /// Move to the exercise after `index` (or back to the chip list if last).
    private func goToNext(after index: Int, markDone: Bool) {
        guard let draft = router.draft else { return }
        if markDone { draft.completed.insert(draft.exercises[index].id) }
        if index + 1 < draft.exercises.count {
            router.workoutPath = [.exercise(index + 1)]    // replace top → auto-advance
        } else {
            router.workoutPath = []
            showToast(markDone ? "Last exercise done — finish to save" : "That was the last exercise")
        }
    }

    private func finish(_ draft: WorkoutDraft) {
        let type = draft.type
        // Captured before inserting the new session, so PR/plateau checks
        // compare against history that doesn't include today's own entries.
        let priorSessions = (try? context.fetch(FetchDescriptor<WorkoutSession>())) ?? []

        let session = WorkoutSession(date: Calendar.current.startOfDay(for: .now), workoutType: type)
        context.insert(session)

        for ex in draft.exercises {
            let logged: [LoggedSet] = draft.sets(for: ex.id).compactMap { r in
                let w = Double(r.weight.replacingOccurrences(of: ",", with: "."))
                let reps = Int(r.reps)
                let hold = Int(r.hold)
                if w == nil && reps == nil && hold == nil { return nil }
                return LoggedSet(weightLb: w, reps: reps, holdSeconds: hold)
            }
            guard !logged.isEmpty else { continue }
            let entry = ExerciseEntry(
                exerciseId: ex.id,
                exerciseName: ex.name,
                weightLb: logged.compactMap(\.weightLb).first,
                repsText: logged.compactMap { $0.reps.map(String.init) }.joined(separator: ","),
                holdSeconds: logged.compactMap(\.holdSeconds).first,
                sets: logged
            )
            session.entries.append(entry)
        }

        guard !session.entries.isEmpty else {
            context.delete(session)
            showToast("Log at least one set first")
            return
        }
        try? context.save()
        checkMilestones(entries: session.entries, priorSessions: priorSessions)

        let hk = HealthKitManager.shared
        if hk.isConnected {
            let est = draft.exercises.count * 8
            Task { await hk.saveWorkout(start: .now, durationMinutes: est) }
        }

        router.draft = WorkoutDraft(type: type, week: draft.week, track: draft.track)
        router.workoutPath = []
        showToast("Workout saved ✓")
    }

    private func showToast(_ msg: String) {
        withAnimation { toast = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toast = nil }
        }
    }

    // MARK: - PR / plateau detection

    private struct BestSet { let weight: Double; let reps: Int }

    private func bestSet(_ sets: [LoggedSet]) -> BestSet? {
        sets.compactMap { set -> BestSet? in
            guard let w = set.weightLb, let r = set.reps else { return nil }
            return BestSet(weight: w, reps: r)
        }.max { estimated1RM($0) < estimated1RM($1) }
    }

    /// Epley-formula estimated 1RM — just a consistent way to compare sets at
    /// different weight/rep combos, not a literal max-strength claim.
    private func estimated1RM(_ set: BestSet) -> Double {
        set.weight * (1 + Double(set.reps) / 30.0)
    }

    /// Fires "new PR" and "3-session plateau" notifications by comparing this
    /// session's logged sets against the same exercise's history.
    private func checkMilestones(entries: [ExerciseEntry], priorSessions: [WorkoutSession]) {
        let sortedPrior = priorSessions.sorted { $0.date > $1.date }
        for entry in entries {
            guard let best = bestSet(entry.sets) else { continue }

            let priorEntries = sortedPrior.compactMap { s in
                s.entries.first { $0.exerciseId == entry.exerciseId }
            }

            let priorBest1RM = priorEntries.compactMap { bestSet($0.sets) }.map(estimated1RM).max()
            if let priorBest1RM, estimated1RM(best) > priorBest1RM {
                NotificationsManager.shared.announcePR(exerciseName: entry.exerciseName, weightLb: best.weight, reps: best.reps)
            }

            let lastTwo = priorEntries.prefix(2).compactMap { bestSet($0.sets) }
            if lastTwo.count == 2, lastTwo.allSatisfy({ $0.weight == best.weight && $0.reps == best.reps }) {
                NotificationsManager.shared.announcePlateau(exerciseName: entry.exerciseName)
            }
        }
    }
}

// MARK: - Exercise chip

struct ExerciseChip: View {
    let exercise: ExerciseDef
    let draft: WorkoutDraft

    var body: some View {
        let done = draft.completed.contains(exercise.id)
        let total = draft.sets(for: exercise.id).count
        let filled = draft.filledCount(exercise.id)
        return HStack(spacing: 14) {
            Color.clear
                .frame(width: 54, height: 54)
                .overlay {
                    RemoteImageView(
                        url: ImageProvider.exerciseURL(exercise, width: 160, height: 160),
                        icon: exercise.kind == .isometric ? "timer" : "dumbbell.fill",
                        cornerRadius: 0,
                        bordered: false
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay {
                    if done {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12).fill(Theme.moss.opacity(0.72))
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(exercise.prescription) · RPE \(exercise.rpe)")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
            Spacer(minLength: 8)
            VStack(spacing: 1) {
                Text("\(filled)/\(total)")
                    .font(Theme.pixel(18))
                    .foregroundStyle(done ? Theme.moss : (filled > 0 ? Theme.ember : Theme.chalkDim))
                Text("sets")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.chalkDim)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(done ? Theme.moss.opacity(0.45) : Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

/// A read-only version of `ExerciseChip` for previewing a non-today scheduled
/// day — no progress/completion state (nothing's been logged for that day)
/// and not tappable, since logging only ever applies to today.
struct PreviewExerciseRow: View {
    let exercise: ExerciseDef

    var body: some View {
        HStack(spacing: 14) {
            Color.clear
                .frame(width: 54, height: 54)
                .overlay {
                    RemoteImageView(
                        url: ImageProvider.exerciseURL(exercise, width: 160, height: 160),
                        icon: exercise.kind == .isometric ? "timer" : "dumbbell.fill",
                        cornerRadius: 0,
                        bordered: false
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 3) {
                Text(exercise.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(exercise.prescription) · RPE \(exercise.rpe)")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
            Spacer(minLength: 8)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

// MARK: - Per-exercise set logger (one set at a time)

struct ExerciseLogView: View {
    let exercise: ExerciseDef
    let position: String
    let isLastExercise: Bool
    let draft: WorkoutDraft
    let onDone: () -> Void
    let onSkip: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var currentSet = 0
    @State private var showLibrary = false
    @State private var rest = IntervalTimer()
    @State private var showRest = false

    private var isIso: Bool { exercise.kind == .isometric }
    private var totalSets: Int { draft.sets(for: exercise.id).count }
    private var isLastSet: Bool { currentSet + 1 >= totalSets }

    /// A genuinely time-based hold (e.g. "30–45s"), vs. a rep-based movement that
    /// happens to be tagged isometric (e.g. hanging knee raise "10–12").
    private var isTimedHold: Bool {
        let chars = Array(exercise.prescription)
        for i in chars.indices.dropLast() where chars[i].isNumber {
            if chars[i + 1] == "s" || chars[i + 1] == "S" { return true }
        }
        return false
    }

    var body: some View {
        // Natural page scroll: the button is the last element in the content and
        // is pushed to the bottom by a spacer (min-height keeps the content at
        // least one screen tall). The whole page scrolls — nothing is pinned. The
        // rest timer appears inline below the set card (not as a modal).
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 16) {
                    topBar
                    exerciseImage
                    titleRow
                    setCard
                    if showRest {
                        RestTimerBar(timer: rest, onDone: dismissRest)
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    Spacer(minLength: 24)
                    actions
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 118)          // clear the floating tab bar
                .frame(minHeight: geo.size.height)
            }
            .scrollContentBackground(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
        .background(Theme.charcoal)
        .dismissKeyboardOnTap()
        .toolbar(.hidden, for: .navigationBar)
        .blurredWhenPresenting(showLibrary)
        .sheet(isPresented: $showLibrary) {
            ExerciseLibrarySheet(current: exercise, onSwap: { newExercise in
                draft.swapExercise(originalId: exercise.id, for: newExercise)
                // Back to the chip list rather than hot-swapping in place —
                // this screen's @State (current set, rest timer) is keyed to
                // the exercise it was pushed with, so a clean re-entry into
                // the (now different) exercise avoids stale set/timer state.
                dismiss()
            })
        }
        .onAppear(perform: prefillFirstSet)
        .onDisappear { rest.stop() }
    }

    /// Fixed-height, hard-clipped photo box so the scaledToFill image can't
    /// bleed over the bar above it or the title below.
    private var exerciseImage: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 216)
            .overlay {
                RemoteImageView(
                    url: ImageProvider.exerciseURL(exercise),
                    icon: "dumbbell.fill",
                    cornerRadius: 0,
                    bordered: false
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }

    private var topBar: some View {
        HStack {
            Button { dismiss() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left").font(.system(size: 14, weight: .semibold))
                    Text("Exercises").font(.system(size: 15, weight: .medium))
                }
                .foregroundStyle(Theme.chalkDim)
            }
            Spacer()
            Text(position)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Theme.chalkDim)
        }
    }

    private var titleRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                Text(exercise.name)
                    .font(Theme.display(24, weight: .bold))
                    .foregroundStyle(Theme.chalk)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer(minLength: 8)
                Button { showLibrary = true } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.left.arrow.right").font(.system(size: 12, weight: .bold))
                        Text("Switch").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Theme.ember)
                }
            }
            Text("\(exercise.prescription)  ·  RPE \(exercise.rpe)  ·  rest \(exercise.restSeconds)s")
                .font(Theme.mono(12))
                .foregroundStyle(Theme.chalkDim)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var setCard: some View {
        VStack(spacing: 16) {
            Text("Set \(currentSet + 1) of \(totalSets)")
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.8)
                .textCase(.uppercase)
                .foregroundStyle(Theme.ember)

            if isTimedHold {
                HoldTimerControl(holdText: binding(\.hold), defaultTarget: targetReps ?? 30)
                    .id(currentSet)
            } else if isIso {
                // Rep-based movement tagged isometric (e.g. hanging knee raise).
                Ticker(title: "Reps", unit: "reps", text: binding(\.reps), step: 1)
            } else {
                Ticker(title: "Weight", unit: "lb", text: binding(\.weight), step: 5)
                Divider().overlay(Theme.hairline)
                Ticker(title: "Reps", unit: "reps", text: binding(\.reps), step: 1)
            }
        }
        .padding(.vertical, 18)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private var actions: some View {
        VStack(spacing: 14) {
            Button {
                if isLastSet { onDone() } else { advanceSet(); startRest() }
            } label: {
                HStack(spacing: 8) {
                    Text(isLastSet ? "Finish exercise" : "Next set")
                    Image(systemName: isLastSet ? "checkmark" : "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .buttonStyle(SteelButtonStyle())

            HStack(spacing: 24) {
                Button(action: addSet) {
                    Text("＋ Add set").font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.chalkDim)
                }
                Button(action: onSkip) {
                    Text("Skip this exercise").font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
        }
        .padding(.top, 4)
    }

    // MARK: Rest timer

    /// Open the rest countdown for the interval prescribed on this exercise.
    private func startRest() {
        rest.start(seconds: max(10, exercise.restSeconds))
        withAnimation(.easeOut(duration: 0.2)) { showRest = true }
    }

    private func dismissRest() {
        rest.stop()
        withAnimation(.easeOut(duration: 0.2)) { showRest = false }
    }

    // MARK: Set editing

    private func binding(_ kp: WritableKeyPath<DraftSet, String>) -> Binding<String> {
        Binding(
            get: { draft.setsByExercise[exercise.id]?[safe: currentSet]?[keyPath: kp] ?? "" },
            set: { newValue in
                guard var arr = draft.setsByExercise[exercise.id], arr.indices.contains(currentSet) else { return }
                arr[currentSet][keyPath: kp] = newValue
                draft.setsByExercise[exercise.id] = arr
            }
        )
    }

    /// Advance to the next set, carrying the current set's values forward.
    private func advanceSet() {
        let id = exercise.id
        let next = currentSet + 1
        guard var arr = draft.setsByExercise[id], next < arr.count, let cur = arr[safe: currentSet] else { return }
        if arr[next].weight.isEmpty { arr[next].weight = cur.weight }
        if arr[next].reps.isEmpty { arr[next].reps = cur.reps }
        if arr[next].hold.isEmpty { arr[next].hold = cur.hold }
        draft.setsByExercise[id] = arr
        currentSet = next
    }

    private func addSet() {
        let id = exercise.id
        guard var arr = draft.setsByExercise[id] else { return }
        var new = DraftSet()
        if let cur = arr[safe: currentSet] { new.weight = cur.weight; new.reps = cur.reps; new.hold = cur.hold }
        arr.append(new)
        draft.setsByExercise[id] = arr
        currentSet = arr.count - 1
    }

    /// Seed the first set's reps/hold with the prescription's target.
    private func prefillFirstSet() {
        guard let target = targetReps, var arr = draft.setsByExercise[exercise.id], let first = arr.first else { return }
        if isTimedHold {
            if first.hold.isEmpty { arr[0].hold = String(target); draft.setsByExercise[exercise.id] = arr }
        } else {
            if first.reps.isEmpty { arr[0].reps = String(target); draft.setsByExercise[exercise.id] = arr }
        }
    }

    /// First integer after the "×" in the prescription (rep or hold target).
    private var targetReps: Int? {
        let s = exercise.prescription
        guard let xi = s.firstIndex(where: { $0 == "×" || $0 == "x" || $0 == "X" }) else { return nil }
        var digits = ""
        for ch in s[s.index(after: xi)...] {
            if ch.isNumber { digits.append(ch) } else if !digits.isEmpty { break }
        }
        return Int(digits)
    }
}

// MARK: - Ticker (stepper) control

/// A big editable number flanked by − / + buttons. Binds directly to a set's
/// String field; tapping the number opens the numeric keyboard for direct entry.
struct Ticker: View {
    let title: String
    let unit: String
    @Binding var text: String
    var step: Double
    var minValue: Double = 0

    private var current: Double { Double(text.replacingOccurrences(of: ",", with: ".")) ?? 0 }

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .tracking(0.6)
                .textCase(.uppercase)
                .foregroundStyle(Theme.chalkDim)
            HStack(spacing: 16) {
                stepButton("minus") { set(current - step) }
                VStack(spacing: 0) {
                    TextField("0", text: $text)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.center)
                        .font(Theme.pixel(40))
                        .foregroundStyle(Theme.chalk)
                        .frame(minWidth: 90)
                        .fixedSize()
                    Text(unit)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Theme.chalkDim)
                }
                stepButton("plus") { set(current + step) }
            }
        }
    }

    private func stepButton(_ icon: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.chalk)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Theme.iron2))
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func set(_ v: Double) {
        let clamped = max(minValue, v)
        text = clamped == clamped.rounded() ? String(Int(clamped)) : String(clamped)
    }
}

// Full exercise library lives in ExerciseLibraryView.swift (ExerciseLibrarySheet).

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
