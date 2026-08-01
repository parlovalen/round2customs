//
//  HealthKitManager.swift
//  RecompCoach
//
//  Apple Health integration. Reads the metrics the dashboard cares about (weight,
//  steps, sleep, resting HR, HRV, active energy, VO2 max) and writes body weight,
//  nutrition, water, and workouts back out — the import/export scope from the
//  handoff. On-device; works with a free personal signing profile.
//

import Foundation
import HealthKit
import Observation

/// One night's sleep, bucketed from Apple Watch stage samples, with an estimated
/// 0–100 score. `date` is the morning you woke up.
struct SleepNight: Identifiable {
    let date: Date
    let totalHours: Double
    let deepHours: Double
    let remHours: Double
    let awakeHours: Double
    let score: Int

    var id: Date { date }
    var deepPct: Double { totalHours > 0 ? deepHours / totalHours : 0 }
    var remPct: Double { totalHours > 0 ? remHours / totalHours : 0 }
}

@Observable
final class HealthKitManager {
    static let shared = HealthKitManager()

    private let store = HKHealthStore()
    private let cal = Calendar.current
    /// Retained so the observer queries aren't deallocated after registration.
    private var observerQueries: [HKObserverQuery] = []
    private var pendingRefresh: Task<Void, Never>?

    /// Persisted flag: have we shown the authorization sheet at least once?
    /// HealthKit deliberately hides read-authorization status, so we track intent
    /// ourselves and simply attempt reads (denied reads return nil, handled gracefully).
    var isConnected: Bool {
        didSet { UserDefaults.standard.set(isConnected, forKey: "hk.connected") }
    }

    var isAvailable: Bool { HKHealthStore.isHealthDataAvailable() }

    // MARK: - Per-category sync toggles (Integrations screen)
    //
    // HealthKit authorization itself is requested broadly up front (see
    // `readTypes`/`writeTypes`) since Apple's grant flow shouldn't be re-run
    // per toggle; these flags instead gate every read/save call below, so
    // turning a category off genuinely stops that data moving in either
    // direction, not just hiding it in the UI. Default on (matches the
    // behavior before these toggles existed).

    var syncReadWeight: Bool {
        didSet { UserDefaults.standard.set(syncReadWeight, forKey: "hk.sync.readWeight") }
    }
    var syncReadActivity: Bool {
        didSet { UserDefaults.standard.set(syncReadActivity, forKey: "hk.sync.readActivity") }
    }
    var syncReadHeart: Bool {
        didSet { UserDefaults.standard.set(syncReadHeart, forKey: "hk.sync.readHeart") }
    }
    var syncReadSleep: Bool {
        didSet { UserDefaults.standard.set(syncReadSleep, forKey: "hk.sync.readSleep") }
    }
    var syncReadNutrition: Bool {
        didSet { UserDefaults.standard.set(syncReadNutrition, forKey: "hk.sync.readNutrition") }
    }
    var syncWriteWeight: Bool {
        didSet { UserDefaults.standard.set(syncWriteWeight, forKey: "hk.sync.writeWeight") }
    }
    var syncWriteNutrition: Bool {
        didSet { UserDefaults.standard.set(syncWriteNutrition, forKey: "hk.sync.writeNutrition") }
    }
    var syncWriteWorkouts: Bool {
        didSet { UserDefaults.standard.set(syncWriteWorkouts, forKey: "hk.sync.writeWorkouts") }
    }

    // Dashboard snapshot (for "today").
    var latestWeightLb: Double?
    var stepsToday: Int?
    var sleepLastNightHours: Double?
    /// Estimated 0–100 sleep score for last night (Apple's own score isn't
    /// exposed to third-party apps, so we approximate it from the Watch stages).
    var sleepScoreLastNight: Int?
    var lastNightSleep: SleepNight?
    var restingHeartRate: Int?
    var hrvMs: Double?
    var activeEnergyToday: Int?
    var vo2Max: Double?
    /// Latest body-fat reading (e.g. from a Wyze Scale synced into Health), as
    /// a 0–100 percentage.
    var latestBodyFatPercent: Double?
    /// Latest lean body mass (fat-free mass), in lb.
    var latestLeanBodyMassLb: Double?
    /// Hours today with an Apple Watch "stood" credit.
    var standHoursToday: Int?
    /// Minutes of brisk activity today (Apple's Exercise ring).
    var exerciseMinutesToday: Int?

    private init() {
        isConnected = UserDefaults.standard.bool(forKey: "hk.connected")
        UserDefaults.standard.register(defaults: [
            "hk.sync.readWeight": true, "hk.sync.readActivity": true,
            "hk.sync.readHeart": true, "hk.sync.readSleep": true, "hk.sync.readNutrition": true,
            "hk.sync.writeWeight": true, "hk.sync.writeNutrition": true, "hk.sync.writeWorkouts": true
        ])
        syncReadWeight = UserDefaults.standard.bool(forKey: "hk.sync.readWeight")
        syncReadActivity = UserDefaults.standard.bool(forKey: "hk.sync.readActivity")
        syncReadHeart = UserDefaults.standard.bool(forKey: "hk.sync.readHeart")
        syncReadSleep = UserDefaults.standard.bool(forKey: "hk.sync.readSleep")
        syncReadNutrition = UserDefaults.standard.bool(forKey: "hk.sync.readNutrition")
        syncWriteWeight = UserDefaults.standard.bool(forKey: "hk.sync.writeWeight")
        syncWriteNutrition = UserDefaults.standard.bool(forKey: "hk.sync.writeNutrition")
        syncWriteWorkouts = UserDefaults.standard.bool(forKey: "hk.sync.writeWorkouts")
    }

    // MARK: - Types

    private func qty(_ id: HKQuantityTypeIdentifier) -> HKQuantityType {
        HKQuantityType.quantityType(forIdentifier: id)!
    }
    private var sleepType: HKCategoryType {
        HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)!
    }

    private var readTypes: Set<HKObjectType> {
        [
            qty(.bodyMass), qty(.stepCount), qty(.activeEnergyBurned),
            qty(.heartRate), qty(.restingHeartRate), qty(.heartRateVariabilitySDNN),
            qty(.vo2Max), sleepType,
            // Dietary reads pick up anything synced into Health by other apps
            // (e.g. MyFitnessPal), not just what RecompCoach itself writes.
            qty(.dietaryEnergyConsumed), qty(.dietaryProtein),
            qty(.dietaryCarbohydrates), qty(.dietaryFatTotal), qty(.dietaryWater),
            // Smart-scale body composition (e.g. Wyze Scale syncs this in).
            // Health has no type for muscle mass % or body water %, so lean
            // body mass (fat-free mass) is the closest available proxy.
            qty(.bodyFatPercentage), qty(.leanBodyMass),
            // Apple's Stand and Exercise activity rings.
            qty(.appleExerciseTime), HKObjectType.categoryType(forIdentifier: .appleStandHour)!
        ]
    }
    private var writeTypes: Set<HKSampleType> {
        [
            qty(.bodyMass), qty(.dietaryEnergyConsumed), qty(.dietaryProtein),
            qty(.dietaryCarbohydrates), qty(.dietaryFatTotal), qty(.dietaryWater),
            HKObjectType.workoutType()
        ]
    }

    // MARK: - Authorization

    @discardableResult
    func requestAuthorization() async -> Bool {
        guard isAvailable else { return false }
        do {
            try await store.requestAuthorization(toShare: writeTypes, read: readTypes)
            await MainActor.run { isConnected = true }
            await refreshSnapshot()
            startObservingUpdates()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Live updates

    /// Registers `HKObserverQuery`s for the metrics the dashboard shows so the
    /// snapshot refreshes itself as new samples land (e.g. an Apple Watch sync),
    /// instead of only updating on pull-to-refresh. Also enables background
    /// delivery so the same observers can wake the app when it isn't foregrounded
    /// (requires the "healthkit" UIBackgroundModes entry, already set on the target).
    private func startObservingUpdates() {
        guard isAvailable, observerQueries.isEmpty else { return }
        let types: [HKSampleType] = [
            qty(.bodyMass), qty(.stepCount), qty(.activeEnergyBurned),
            qty(.restingHeartRate), qty(.heartRateVariabilitySDNN),
            qty(.bodyFatPercentage), qty(.leanBodyMass), sleepType
        ]
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completionHandler, _ in
                self?.scheduleRefresh()
                completionHandler()
            }
            store.execute(query)
            observerQueries.append(query)
            store.enableBackgroundDelivery(for: type, frequency: .hourly) { _, _ in }
        }
    }

    /// Debounces refreshes so a burst of observer callbacks (a Watch sync
    /// touches several types at once) triggers one `refreshSnapshot()`, not several.
    private func scheduleRefresh() {
        pendingRefresh?.cancel()
        pendingRefresh = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000)
            guard !Task.isCancelled else { return }
            await self?.refreshSnapshot()
        }
    }

    // MARK: - Reads

    /// Pull the dashboard-relevant metrics for today / most recent.
    func refreshSnapshot() async {
        guard isAvailable else { return }
        async let weight = syncReadWeight ? await latestQuantity(qty(.bodyMass), unit: .pound()) : nil
        async let steps = syncReadActivity ? await sumToday(qty(.stepCount), unit: .count()) : nil
        async let energy = syncReadActivity ? await sumToday(qty(.activeEnergyBurned), unit: .kilocalorie()) : nil
        async let rhr = syncReadHeart ? await latestQuantity(qty(.restingHeartRate), unit: HKUnit.count().unitDivided(by: .minute())) : nil
        async let hrv = syncReadHeart ? await latestQuantity(qty(.heartRateVariabilitySDNN), unit: HKUnit.secondUnit(with: .milli)) : nil
        async let vo2 = syncReadHeart ? await latestQuantity(qty(.vo2Max),
            unit: HKUnit.literUnit(with: .milli).unitDivided(by: HKUnit.gramUnit(with: .kilo).unitMultiplied(by: .minute()))) : nil
        async let nights = syncReadSleep ? await sleepNights(days: 2) : []
        async let bodyFat = syncReadWeight ? await latestQuantity(qty(.bodyFatPercentage), unit: .percent()) : nil
        async let leanMass = syncReadWeight ? await latestQuantity(qty(.leanBodyMass), unit: .pound()) : nil
        async let exerciseMin = syncReadActivity ? await sumToday(qty(.appleExerciseTime), unit: .minute()) : nil
        async let standHours = syncReadActivity ? await standHoursToday() : nil

        let (w, s, e, r, h, v, ns, bf, lm, ex, sh) = await (weight, steps, energy, rhr, hrv, vo2, nights, bodyFat, leanMass, exerciseMin, standHours)
        let lastNight = ns.last
        await MainActor.run {
            self.latestWeightLb = w
            self.stepsToday = s.map { Int($0.rounded()) }
            self.activeEnergyToday = e.map { Int($0.rounded()) }
            self.restingHeartRate = r.map { Int($0.rounded()) }
            self.hrvMs = h
            self.vo2Max = v
            self.sleepLastNightHours = lastNight?.totalHours
            self.sleepScoreLastNight = lastNight?.score
            self.lastNightSleep = lastNight
            // HealthKit reports body fat as a 0–1 fraction even with the
            // `.percent()` unit, so scale it up to a human 0–100 percentage.
            self.latestBodyFatPercent = bf.map { $0 * 100 }
            self.latestLeanBodyMassLb = lm
            self.exerciseMinutesToday = ex.map { Int($0.rounded()) }
            self.standHoursToday = sh
        }
    }

    /// Distinct hours today with a "stood" credit (Apple's Stand ring).
    private func standHoursToday() async -> Int? {
        guard isAvailable else { return nil }
        let start = cal.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        let type = HKCategoryType.categoryType(forIdentifier: .appleStandHour)!
        return await withCheckedContinuation { continuation in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                let hours = Set((samples as? [HKCategorySample])?
                    .filter { $0.value == HKCategoryValueAppleStandHour.stood.rawValue }
                    .map { self.cal.component(.hour, from: $0.startDate) } ?? [])
                continuation.resume(returning: hours.count)
            }
            self.store.execute(q)
        }
    }

    /// Most recent sample value for a quantity type.
    private func latestQuantity(_ type: HKQuantityType, unit: HKUnit) async -> Double? {
        await withCheckedContinuation { continuation in
            let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
            let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
                let value = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(q)
        }
    }

    /// Cumulative sum of a quantity over today.
    private func sumToday(_ type: HKQuantityType, unit: HKUnit) async -> Double? {
        let start = cal.startOfDay(for: .now)
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: .strictStartDate)
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: unit)
                continuation.resume(returning: value)
            }
            store.execute(q)
        }
    }

    /// Daily cumulative step totals for the last `days` days (today inclusive),
    /// oldest first. Health keeps this history indefinitely, so past days show
    /// up here even though the app never logged them itself.
    func dailySteps(days: Int) async -> [(date: Date, value: Int)] {
        guard isAvailable, syncReadActivity, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsCollectionQuery(
                quantityType: qty(.stepCount), quantitySamplePredicate: nil,
                options: .cumulativeSum, anchorDate: todayStart, intervalComponents: interval
            )
            q.initialResultsHandler = { _, results, _ in
                var out: [(Date, Int)] = []
                results?.enumerateStatistics(from: start, to: end) { stats, _ in
                    if let sum = stats.sumQuantity()?.doubleValue(for: .count()) {
                        out.append((cal.startOfDay(for: stats.startDate), Int(sum.rounded())))
                    }
                }
                continuation.resume(returning: out)
            }
            store.execute(q)
        }
    }

    /// Most-recent body mass (lb) per day for the last `days` days (today
    /// inclusive), oldest first.
    func dailyWeights(days: Int) async -> [(date: Date, value: Double)] {
        guard isAvailable, syncReadWeight, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsCollectionQuery(
                quantityType: qty(.bodyMass), quantitySamplePredicate: nil,
                options: .mostRecent, anchorDate: todayStart, intervalComponents: interval
            )
            q.initialResultsHandler = { _, results, _ in
                var out: [(Date, Double)] = []
                results?.enumerateStatistics(from: start, to: end) { stats, _ in
                    if let v = stats.mostRecentQuantity()?.doubleValue(for: .pound()) {
                        out.append((cal.startOfDay(for: stats.startDate), v))
                    }
                }
                continuation.resume(returning: out)
            }
            store.execute(q)
        }
    }

    /// Most-recent body-fat % per day for the last `days` days (today
    /// inclusive), oldest first — e.g. from a Wyze Scale synced into Health.
    func dailyBodyFat(days: Int) async -> [(date: Date, value: Double)] {
        guard isAvailable, syncReadWeight, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsCollectionQuery(
                quantityType: qty(.bodyFatPercentage), quantitySamplePredicate: nil,
                options: .mostRecent, anchorDate: todayStart, intervalComponents: interval
            )
            q.initialResultsHandler = { _, results, _ in
                var out: [(Date, Double)] = []
                results?.enumerateStatistics(from: start, to: end) { stats, _ in
                    if let v = stats.mostRecentQuantity()?.doubleValue(for: .percent()) {
                        out.append((cal.startOfDay(for: stats.startDate), v * 100))
                    }
                }
                continuation.resume(returning: out)
            }
            store.execute(q)
        }
    }

    /// Cumulative exercise minutes (Apple's Exercise ring) per day for the
    /// last `days` days (today inclusive), oldest first.
    func dailyExerciseMinutes(days: Int) async -> [(date: Date, value: Int)] {
        guard isAvailable, syncReadActivity, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsCollectionQuery(
                quantityType: qty(.appleExerciseTime), quantitySamplePredicate: nil,
                options: .cumulativeSum, anchorDate: todayStart, intervalComponents: interval
            )
            q.initialResultsHandler = { _, results, _ in
                var out: [(Date, Int)] = []
                results?.enumerateStatistics(from: start, to: end) { stats, _ in
                    if let sum = stats.sumQuantity()?.doubleValue(for: .minute()) {
                        out.append((cal.startOfDay(for: stats.startDate), Int(sum.rounded())))
                    }
                }
                continuation.resume(returning: out)
            }
            store.execute(q)
        }
    }

    /// Distinct "stood" hours (Apple's Stand ring) per day for the last `days`
    /// days (today inclusive), oldest first. One sample query, bucketed by day
    /// client-side — mirrors `sleepNights`'s approach for category samples.
    func dailyStandHours(days: Int) async -> [(date: Date, value: Int)] {
        guard isAvailable, syncReadActivity, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let predicate = HKQuery.predicateForSamples(withStart: start, end: .now, options: [])
        let type = HKCategoryType.categoryType(forIdentifier: .appleStandHour)!

        let samples: [HKCategorySample] = await withCheckedContinuation { continuation in
            let q = HKSampleQuery(sampleType: type, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }

        var stoodHoursByDay: [Date: Set<Int>] = [:]
        for sample in samples where sample.value == HKCategoryValueAppleStandHour.stood.rawValue {
            let day = cal.startOfDay(for: sample.startDate)
            stoodHoursByDay[day, default: []].insert(cal.component(.hour, from: sample.startDate))
        }
        return stoodHoursByDay.map { (date: $0.key, value: $0.value.count) }.sorted { $0.date < $1.date }
    }

    /// Most-recent lean body mass (lb) per day for the last `days` days (today
    /// inclusive), oldest first.
    func dailyLeanBodyMass(days: Int) async -> [(date: Date, value: Double)] {
        guard isAvailable, syncReadWeight, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1
        return await withCheckedContinuation { continuation in
            let q = HKStatisticsCollectionQuery(
                quantityType: qty(.leanBodyMass), quantitySamplePredicate: nil,
                options: .mostRecent, anchorDate: todayStart, intervalComponents: interval
            )
            q.initialResultsHandler = { _, results, _ in
                var out: [(Date, Double)] = []
                results?.enumerateStatistics(from: start, to: end) { stats, _ in
                    if let v = stats.mostRecentQuantity()?.doubleValue(for: .pound()) {
                        out.append((cal.startOfDay(for: stats.startDate), v))
                    }
                }
                continuation.resume(returning: out)
            }
            store.execute(q)
        }
    }

    /// Dietary energy/macros logged for a day by any source Health knows about
    /// — including third-party apps like MyFitnessPal that sync their food
    /// diary into Health. `nil` if Health has nothing for that day at all.
    func dietaryTotals(for day: Date) async -> NutritionTotals? {
        guard isAvailable, syncReadNutrition else { return nil }
        let start = cal.startOfDay(for: day)
        guard let end = cal.date(byAdding: .day, value: 1, to: start) else { return nil }
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)
        async let kcal = sum(qty(.dietaryEnergyConsumed), unit: .kilocalorie(), predicate: predicate)
        async let protein = sum(qty(.dietaryProtein), unit: .gram(), predicate: predicate)
        async let carb = sum(qty(.dietaryCarbohydrates), unit: .gram(), predicate: predicate)
        async let fat = sum(qty(.dietaryFatTotal), unit: .gram(), predicate: predicate)
        let (k, p, c, f) = await (kcal, protein, carb, fat)
        guard k != nil || p != nil || c != nil || f != nil else { return nil }
        return NutritionTotals(
            kcal: Int((k ?? 0).rounded()), protein: Int((p ?? 0).rounded()),
            carb: Int((c ?? 0).rounded()), fat: Int((f ?? 0).rounded()), meals: 0
        )
    }

    /// Day-bucketed dietary totals for the last `days` days (today inclusive),
    /// oldest first — lets past-day history include nutrition apps like
    /// MyFitnessPal that sync into Health, even for days never logged in
    /// RecompCoach itself. Days with nothing in Health are omitted.
    func dailyDietaryTotals(days: Int) async -> [(date: Date, totals: NutritionTotals)] {
        guard isAvailable, syncReadNutrition, days > 0 else { return [] }
        let cal = self.cal
        let todayStart = cal.startOfDay(for: .now)
        let start = cal.date(byAdding: .day, value: -(days - 1), to: todayStart) ?? todayStart
        let end = cal.date(byAdding: .day, value: 1, to: todayStart) ?? .now
        var interval = DateComponents()
        interval.day = 1

        func dailySums(_ id: HKQuantityTypeIdentifier, unit: HKUnit) async -> [Date: Double] {
            await withCheckedContinuation { continuation in
                let q = HKStatisticsCollectionQuery(
                    quantityType: qty(id), quantitySamplePredicate: nil,
                    options: .cumulativeSum, anchorDate: todayStart, intervalComponents: interval
                )
                q.initialResultsHandler = { _, results, _ in
                    var out: [Date: Double] = [:]
                    results?.enumerateStatistics(from: start, to: end) { stats, _ in
                        if let sum = stats.sumQuantity()?.doubleValue(for: unit) {
                            out[cal.startOfDay(for: stats.startDate)] = sum
                        }
                    }
                    continuation.resume(returning: out)
                }
                store.execute(q)
            }
        }

        async let kcalByDay = dailySums(.dietaryEnergyConsumed, unit: .kilocalorie())
        async let proteinByDay = dailySums(.dietaryProtein, unit: .gram())
        async let carbByDay = dailySums(.dietaryCarbohydrates, unit: .gram())
        async let fatByDay = dailySums(.dietaryFatTotal, unit: .gram())
        let (k, p, c, f) = await (kcalByDay, proteinByDay, carbByDay, fatByDay)

        let allDays = Set(k.keys).union(p.keys).union(c.keys).union(f.keys)
        return allDays.sorted().compactMap { day in
            let totals = NutritionTotals(
                kcal: Int((k[day] ?? 0).rounded()), protein: Int((p[day] ?? 0).rounded()),
                carb: Int((c[day] ?? 0).rounded()), fat: Int((f[day] ?? 0).rounded()), meals: 0
            )
            guard totals.kcal > 0 || totals.protein > 0 || totals.carb > 0 || totals.fat > 0 else { return nil }
            return (day, totals)
        }
    }

    /// Cumulative sum of a quantity over an arbitrary predicate window.
    private func sum(_ type: HKQuantityType, unit: HKUnit, predicate: NSPredicate) async -> Double? {
        await withCheckedContinuation { continuation in
            let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, stats, _ in
                continuation.resume(returning: stats?.sumQuantity()?.doubleValue(for: unit))
            }
            store.execute(q)
        }
    }

    /// Per-night sleep summaries (with an estimated score) for the last `days`
    /// nights, oldest first. One HealthKit query; samples are bucketed into
    /// nights by the day you woke up.
    func sleepNights(days: Int) async -> [SleepNight] {
        guard isAvailable, syncReadSleep else { return [] }
        let end = Date()
        let start = cal.date(byAdding: .day, value: -(days + 1), to: cal.startOfDay(for: end)) ?? end
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: [])

        let samples: [HKCategorySample] = await withCheckedContinuation { continuation in
            let q = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { _, samples, _ in
                continuation.resume(returning: (samples as? [HKCategorySample]) ?? [])
            }
            store.execute(q)
        }

        // Accumulate stage seconds per night.
        var buckets: [Date: (deep: Double, rem: Double, core: Double, awake: Double)] = [:]
        for sample in samples {
            let dur = sample.endDate.timeIntervalSince(sample.startDate)
            guard dur > 0 else { continue }
            let key = nightKey(for: sample.startDate)
            var b = buckets[key] ?? (0, 0, 0, 0)
            switch Self.stage(sample.value) {
            case .deep: b.deep += dur
            case .rem: b.rem += dur
            case .core: b.core += dur
            case .awake: b.awake += dur
            case .ignored: break
            }
            buckets[key] = b
        }

        let cutoff = cal.date(byAdding: .day, value: -days, to: cal.startOfDay(for: end)) ?? end
        return buckets.compactMap { key, b -> SleepNight? in
            let asleep = b.deep + b.rem + b.core
            guard asleep >= 2 * 3600 else { return nil }   // ignore naps / stray samples
            let score = Self.sleepScore(
                totalHours: asleep / 3600,
                deepPct: b.deep / asleep,
                remPct: b.rem / asleep,
                awakeFrac: b.awake / (asleep + b.awake)
            )
            return SleepNight(
                date: key, totalHours: asleep / 3600,
                deepHours: b.deep / 3600, remHours: b.rem / 3600, awakeHours: b.awake / 3600,
                score: score
            )
        }
        .filter { $0.date >= cutoff }
        .sorted { $0.date < $1.date }
    }

    /// The night a sample belongs to = the morning you wake up. Anything starting
    /// at/after 18:00 counts toward the next day's night.
    private func nightKey(for date: Date) -> Date {
        let base = cal.startOfDay(for: date)
        return cal.component(.hour, from: date) >= 18
            ? (cal.date(byAdding: .day, value: 1, to: base) ?? base)
            : base
    }

    private enum SleepStage { case deep, rem, core, awake, ignored }

    private static func stage(_ value: Int) -> SleepStage {
        switch value {
        case HKCategoryValueSleepAnalysis.asleepDeep.rawValue: return .deep
        case HKCategoryValueSleepAnalysis.asleepREM.rawValue: return .rem
        case HKCategoryValueSleepAnalysis.asleepCore.rawValue,
             HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue: return .core
        case HKCategoryValueSleepAnalysis.awake.rawValue: return .awake
        default: return .ignored   // inBed and anything else
        }
    }

    /// Approximate Apple's 0–100 sleep score: mostly duration (vs. 8h), plus
    /// healthy Deep/REM proportions and a small penalty for time awake. Apple's
    /// exact formula is private, so this tracks it but won't match to the point.
    private static func sleepScore(totalHours: Double, deepPct: Double, remPct: Double, awakeFrac: Double) -> Int {
        let duration = min(1, totalHours / 8.0) * 55
        let deep = min(1, deepPct / 0.15) * 20        // ~15% deep is healthy
        let rem = min(1, remPct / 0.20) * 20          // ~20% REM is healthy
        let continuity = (1 - min(1, awakeFrac / 0.10)) * 5
        return max(0, min(100, Int((duration + deep + rem + continuity).rounded())))
    }

    // MARK: - Writes

    func saveBodyMass(lb: Double, date: Date) async {
        guard isAvailable, isConnected, syncWriteWeight else { return }
        let sample = HKQuantitySample(
            type: qty(.bodyMass),
            quantity: HKQuantity(unit: .pound(), doubleValue: lb),
            start: date, end: date
        )
        try? await store.save(sample)
    }

    /// Save any provided nutrition values for a day. Skips nils.
    func saveNutrition(kcal: Int?, proteinG: Int?, carbG: Int?, fatG: Int?, waterL: Double?, date: Date) async {
        guard isAvailable, isConnected, syncWriteNutrition else { return }
        var samples: [HKQuantitySample] = []
        func add(_ id: HKQuantityTypeIdentifier, _ unit: HKUnit, _ value: Double?) {
            guard let value else { return }
            samples.append(HKQuantitySample(type: qty(id),
                quantity: HKQuantity(unit: unit, doubleValue: value), start: date, end: date))
        }
        add(.dietaryEnergyConsumed, .kilocalorie(), kcal.map(Double.init))
        add(.dietaryProtein, .gram(), proteinG.map(Double.init))
        add(.dietaryCarbohydrates, .gram(), carbG.map(Double.init))
        add(.dietaryFatTotal, .gram(), fatG.map(Double.init))
        add(.dietaryWater, .liter(), waterL)
        guard !samples.isEmpty else { return }
        try? await store.save(samples)
    }

    /// Save a strength-training workout of the given duration.
    func saveWorkout(start: Date, durationMinutes: Int) async {
        guard isAvailable, isConnected, syncWriteWorkouts, durationMinutes > 0 else { return }
        let end = cal.date(byAdding: .minute, value: durationMinutes, to: start) ?? start.addingTimeInterval(Double(durationMinutes) * 60)
        let config = HKWorkoutConfiguration()
        config.activityType = .traditionalStrengthTraining
        let builder = HKWorkoutBuilder(healthStore: store, configuration: config, device: .local())
        do {
            try await builder.beginCollection(at: start)
            try await builder.endCollection(at: end)
            _ = try await builder.finishWorkout()
        } catch {
            // Non-fatal: workout export is best-effort.
        }
    }
}
