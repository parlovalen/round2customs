//
//  FoodView.swift
//  RecompCoach
//
//  The Food tab (tab 3): today's calorie/macro rollup vs. targets, the day's
//  three planned meals (tap to log or view the recipe), and a history of
//  previously logged meals grouped by day. Reads the same MealLog rows that
//  logging a meal writes, so anything you log shows up here.
//

import SwiftUI
import SwiftData

// MARK: - Nutrition totals

/// Rolled-up macros for a set of logged meals.
struct NutritionTotals {
    var kcal = 0
    var protein = 0
    var carb = 0
    var fat = 0
    var meals = 0

    static func sum(_ logs: [MealLog]) -> NutritionTotals {
        logs.reduce(into: NutritionTotals()) { t, m in
            t.kcal += m.kcal
            t.protein += m.proteinG
            t.carb += m.carbG
            t.fat += m.fatG
            t.meals += 1
        }
    }

    /// Combine app-logged meals with a second source (e.g. HealthKit's
    /// dietary totals, which picks up MyFitnessPal and similar synced apps).
    static func + (lhs: NutritionTotals, rhs: NutritionTotals) -> NutritionTotals {
        NutritionTotals(
            kcal: lhs.kcal + rhs.kcal, protein: lhs.protein + rhs.protein,
            carb: lhs.carb + rhs.carb, fat: lhs.fat + rhs.fat, meals: lhs.meals + rhs.meals
        )
    }
}

// MARK: - Food tab

struct FoodView: View {
    @Environment(\.modelContext) private var context
    @Environment(HealthKitManager.self) private var health
    @Environment(AppRouter.self) private var router
    @Query private var profiles: [UserProfile]
    @Query(sort: \MealLog.loggedAt, order: .reverse) private var mealLogs: [MealLog]
    @Query private var supplementLogs: [SupplementLog]

    /// Dietary totals Health knows about for today from any source — this is
    /// how MyFitnessPal (and similar) logs show up, since MFP syncs its food
    /// diary into Health rather than exposing a direct API integration.
    @State private var healthTotals: NutritionTotals?
    /// Health-sourced dietary totals per past day (e.g. MyFitnessPal synced
    /// entries), keyed by start-of-day — merged into the history list below
    /// so days logged purely through a synced app still show up.
    @State private var healthPastTotals: [Date: NutritionTotals] = [:]

    private var cal: Calendar { Calendar.current }
    private var profile: UserProfile? { profiles.first }
    private var today: Date { cal.startOfDay(for: .now) }
    private var programDay: Int { profile.map { ProgramClock.dayNumber(start: $0.startDate) } ?? 1 }
    private var todayPlan: MealDay { MealCatalog.day(forProgramDay: programDay) }

    private var todayLogs: [MealLog] { mealLogs.filter { cal.isDate($0.date, inSameDayAs: today) } }

    /// Previously logged meals (before today), newest day first — including
    /// days with only Health-sourced nutrition and no in-app `MealLog` at all.
    private var pastByDay: [(day: Date, logs: [MealLog], healthTotals: NutritionTotals?)] {
        let past = mealLogs.filter { !cal.isDate($0.date, inSameDayAs: today) }
        let groups = Dictionary(grouping: past) { cal.startOfDay(for: $0.date) }
        var days = Set(groups.keys)
        for day in healthPastTotals.keys where !cal.isDate(day, inSameDayAs: today) {
            days.insert(day)
        }
        return days.map { day in
            (day: day, logs: (groups[day] ?? []).sorted { $0.loggedAt < $1.loggedAt }, healthTotals: healthPastTotals[day])
        }
        .sorted { $0.day > $1.day }
    }

    var body: some View {
        @Bindable var router = router
        return NavigationStack(path: $router.foodPath) {
            ScrollView {
                VStack(spacing: 16) {
                    summaryCard
                    WaterTrackerCard(day: today, target: profile?.waterTargetL ?? 3.75)
                    todaySection
                    supplementsSection
                    if !pastByDay.isEmpty { historySection }
                }
                .padding(16)
                .padding(.bottom, 110)
            }
            .scrollContentBackground(.hidden)
            .toolbar(.hidden, for: .navigationBar)
            .task(id: today) {
                guard health.isAvailable, health.isConnected else { return }
                healthTotals = await health.dietaryTotals(for: today)
            }
            .task(id: health.isConnected) {
                guard health.isAvailable, health.isConnected else { return }
                let vals = await health.dailyDietaryTotals(days: 30)
                healthPastTotals = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), $0.totals) })
            }
            .navigationDestination(for: HomeRoute.self) { route in
                switch route {
                case .meal(let meal, let day): MealDetailView(meal: meal, day: day)
                case .stat(let kind): StatDetailView(kind: kind, day: today)
                }
            }
        }
    }

    private var summaryCard: some View {
        Button {
            router.foodPath.append(HomeRoute.stat(.calories))
        } label: {
            DailyNutritionCard(
                totals: .sum(todayLogs) + (healthTotals ?? NutritionTotals()),
                calorieTarget: profile?.dailyCalorieTarget ?? 2600,
                proteinTarget: profile?.proteinTargetG ?? 185,
                carbTarget: profile?.carbTargetG ?? 285,
                fatTarget: profile?.fatTargetG ?? 80,
                includesHealthData: (healthTotals?.kcal ?? 0) > 0
            )
        }
        .buttonStyle(.plain)
    }

    private var todaySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Today's meals", trailing: "Plan \(todayPlan.id)")
            ForEach(todayPlan.all) { meal in
                Button { router.foodPath.append(HomeRoute.meal(meal, today)) } label: {
                    MealRow(meal: meal, logged: isLogged(meal, on: today))
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var supplementsSection: some View {
        let taken = SupplementCatalog.recommended.filter { isSuppTaken($0, on: today) }.count
        return VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Supplements", trailing: "\(taken)/\(SupplementCatalog.recommended.count) today")
            ForEach(SupplementCatalog.recommended) { def in
                SupplementRow(def: def, taken: isSuppTaken(def, on: today)) {
                    toggleSupplement(def)
                }
            }
        }
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader("Recently logged", trailing: nil)
            ForEach(pastByDay, id: \.day) { group in
                DayLogCard(day: group.day, logs: group.logs, healthTotals: group.healthTotals)
            }
        }
    }

    private func isSuppTaken(_ def: SupplementDef, on day: Date) -> Bool {
        supplementLogs.contains { $0.supplementId == def.id && cal.isDate($0.date, inSameDayAs: day) }
    }

    private func toggleSupplement(_ def: SupplementDef) {
        let d = cal.startOfDay(for: today)
        if let existing = supplementLogs.first(where: {
            $0.supplementId == def.id && cal.isDate($0.date, inSameDayAs: d)
        }) {
            context.delete(existing)
        } else {
            context.insert(SupplementLog(date: d, supplementId: def.id))
        }
        try? context.save()
    }

    private func sectionHeader(_ title: String, trailing: String?) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(Theme.display(18, weight: .bold))
                .foregroundStyle(Theme.chalk)
            Spacer()
            if let trailing {
                Text(trailing)
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
    }

    private func isLogged(_ meal: MealDef, on day: Date) -> Bool {
        mealLogs.contains { $0.mealId == meal.id && cal.isDate($0.date, inSameDayAs: day) }
    }
}

// MARK: - Daily nutrition summary card (shared with Home)

/// A warm hero card: a calorie ring (consumed vs. target) plus protein/carb/fat
/// progress bars. Used on the Food tab and, tappable, on Home.
struct DailyNutritionCard: View {
    let totals: NutritionTotals
    let calorieTarget: Int
    let proteinTarget: Int
    let carbTarget: Int
    let fatTarget: Int
    var title: String = "Today's Fuel"
    /// True when some of `totals` came from Apple Health rather than the
    /// app's own meal logging (e.g. synced from MyFitnessPal).
    var includesHealthData: Bool = false

    private var pct: Double {
        calorieTarget > 0 ? min(1, Double(totals.kcal) / Double(calorieTarget)) : 0
    }

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.ember)
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Spacer(minLength: 0)
                    if includesHealthData {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 9))
                            .foregroundStyle(Theme.rust)
                    }
                    Text("\(min(totals.meals, 3))/3 meals")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.chalkDim)
                }
                MacroBar(label: "Protein", value: totals.protein, target: proteinTarget, color: Theme.ember)
                MacroBar(label: "Carbs", value: totals.carb, target: carbTarget, color: Color(hex: 0xE0A22E))
                MacroBar(label: "Fat", value: totals.fat, target: fatTarget, color: Theme.moss)
            }
            CircularRing(progress: pct, lineWidth: 11) {
                VStack(spacing: 0) {
                    Text("\(totals.kcal)")
                        .font(Theme.pixel(28))
                        .foregroundStyle(Theme.chalk)
                    Text("/ \(calorieTarget)")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                    Text("kcal")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
            .frame(width: 106, height: 106)
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

/// A labelled macro progress bar (consumed / target grams).
struct MacroBar: View {
    let label: String
    let value: Int
    let target: Int
    var color: Color = Theme.ember

    private var frac: Double { target > 0 ? min(1, Double(value) / Double(target)) : 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(Theme.chalkDim)
                Spacer()
                Text("\(value) / \(target)g")
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

// MARK: - Today's meal row

struct MealRow: View {
    let meal: MealDef
    let logged: Bool

    var body: some View {
        HStack(spacing: 14) {
            Color.clear
                .frame(width: 52, height: 52)
                .overlay {
                    RemoteImageView(
                        url: ImageProvider.mealURL(meal, width: 160, height: 160),
                        icon: meal.type.icon,
                        cornerRadius: 0,
                        bordered: false
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Theme.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 3) {
                Text(meal.type.display.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(0.6)
                    .foregroundStyle(Theme.ember)
                Text(meal.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                    .fixedSize(horizontal: false, vertical: true)
                Text("\(meal.kcal) kcal · \(meal.proteinG)g protein")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
            Spacer(minLength: 8)
            if logged {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(Theme.moss)
            } else {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(logged ? Theme.moss.opacity(0.4) : Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

// MARK: - Past-day log group

struct DayLogCard: View {
    let day: Date
    let logs: [MealLog]
    /// Additional dietary totals Health has for this day (e.g. MyFitnessPal
    /// synced entries) that aren't backed by an in-app `MealLog` row.
    var healthTotals: NutritionTotals? = nil

    private var totals: NutritionTotals { .sum(logs) + (healthTotals ?? NutritionTotals()) }
    private var includesHealthData: Bool { (healthTotals?.kcal ?? 0) > 0 }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(day, format: .dateTime.weekday(.wide).month().day())
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                Spacer()
                if includesHealthData {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 9))
                        .foregroundStyle(Theme.rust)
                }
                Text("\(totals.kcal) kcal · \(totals.protein)g P")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
            ForEach(logs, id: \.persistentModelID) { log in
                HStack(spacing: 8) {
                    Image(systemName: MealType(rawValue: log.mealTypeRaw)?.icon ?? "fork.knife")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.ember)
                        .frame(width: 16)
                    Text(log.name)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                    Spacer()
                    Text("\(log.kcal)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
            if logs.isEmpty && includesHealthData {
                HStack(spacing: 8) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Theme.rust)
                        .frame(width: 16)
                    Text("Synced from Apple Health")
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                    Spacer()
                    Text("\(totals.kcal)")
                        .font(Theme.mono(11))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

// MARK: - Water tracker

/// A day's hydration, stored on that day's `DailyLog.waterL`. Adjusts in 250 ml
/// glasses; upserts the DailyLog on demand.
struct WaterTrackerCard: View {
    let day: Date
    let target: Double

    @Environment(\.modelContext) private var context
    @Query private var dailyLogs: [DailyLog]

    private static let ozPerLiter = 33.814
    private static let serving = 8.0 / ozPerLiter   // one 8 oz cup, stored in liters
    private let water = Theme.water
    private var cal: Calendar { Calendar.current }

    private var log: DailyLog? { dailyLogs.first { cal.isDate($0.date, inSameDayAs: day) } }
    private var current: Double { log?.waterL ?? 0 }
    private var frac: Double { target > 0 ? min(1, current / target) : 0 }
    private var currentOz: Int { Int((current * Self.ozPerLiter).rounded()) }
    private var targetOz: Int { Int((target * Self.ozPerLiter).rounded()) }
    private var cups: Int { Int((current / Self.serving).rounded()) }
    private var targetCups: Int { Int((target / Self.serving).rounded()) }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(water)
                Text("Water")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                Spacer(minLength: 0)
                Text("\(currentOz) / \(targetOz) oz")
                    .font(Theme.mono(12))
                    .foregroundStyle(Theme.chalkDim)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule().fill(water).frame(width: max(0, geo.size.width * frac))
                }
            }
            .frame(height: 10)

            HStack(spacing: 12) {
                Text("\(cups) of \(targetCups) cups")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Theme.chalkDim)
                Spacer()
                circleButton("minus") { adjust(-Self.serving) }
                Button { adjust(Self.serving) } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus").font(.system(size: 13, weight: .bold))
                        Text("8 oz").font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.vertical, 9)
                    .padding(.horizontal, 16)
                    .background(water)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }

    private func circleButton(_ icon: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(Theme.chalk)
                .frame(width: 40, height: 40)
                .background(Circle().fill(Theme.iron2))
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func adjust(_ delta: Double) {
        let d = cal.startOfDay(for: day)
        let entry = log ?? {
            let n = DailyLog(date: d)
            context.insert(n)
            return n
        }()
        entry.waterL = max(0, (entry.waterL ?? 0) + delta)
        try? context.save()
    }
}

// MARK: - Supplement row

struct SupplementRow: View {
    let def: SupplementDef
    let taken: Bool
    let onToggle: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: def.icon)
                .font(.system(size: 17))
                .foregroundStyle(Theme.ember)
                .frame(width: 38, height: 38)
                .background(Circle().fill(Theme.iron2))
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(def.name)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                        .fixedSize(horizontal: false, vertical: true)
                    TagBadge(tag: def.tag)
                }
                Text("\(def.dose) · \(def.timing)")
                    .font(Theme.mono(11))
                    .foregroundStyle(Theme.chalkDim)
            }
            Spacer(minLength: 8)
            Button(action: onToggle) {
                if taken {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 26))
                        .foregroundStyle(Theme.moss)
                } else {
                    Text("Log")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 7)
                        .padding(.horizontal, 15)
                        .background(Theme.ember)
                        .clipShape(Capsule())
                }
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(taken ? Theme.moss.opacity(0.4) : Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

/// Small coloured evidence-strength pill.
struct TagBadge: View {
    let tag: SupplementTag

    var body: some View {
        Text(tag.rawValue)
            .font(.system(size: 9, weight: .bold))
            .tracking(0.3)
            .textCase(.uppercase)
            .foregroundStyle(tag.color)
            .padding(.vertical, 2)
            .padding(.horizontal, 6)
            .background(tag.color.opacity(0.15))
            .clipShape(Capsule())
    }
}
