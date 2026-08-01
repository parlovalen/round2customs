//
//  StatDetailView.swift
//  RecompCoach
//
//  Drill-in for a Home stat chip (weight / steps / sleep / knee): current value
//  and recent change up top, a week/month trend chart below, summary tiles, and
//  a shortcut to log or edit the day's entry.
//

import SwiftUI
import SwiftData
import Charts

// MARK: - Which stat

enum StatKind: String, Identifiable, Hashable, CaseIterable {
    case weight, steps, sleep, knee, bodyFat, leanMass, calories, water

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weight: return "Weight"
        case .steps: return "Steps"
        case .sleep: return "Sleep"
        case .knee: return "Knee Pain"
        case .bodyFat: return "Body Fat"
        case .leanMass: return "Lean Mass"
        case .calories: return "Calories"
        case .water: return "Water"
        }
    }

    var unit: String {
        switch self {
        case .weight: return "lb"
        case .steps: return ""
        case .sleep: return "h"
        case .knee: return "/10"
        case .bodyFat: return "%"
        case .leanMass: return "lb"
        case .calories: return "kcal"
        case .water: return "oz"
        }
    }

    var icon: String {
        switch self {
        case .weight: return "scalemass"
        case .steps: return "figure.walk"
        case .sleep: return "moon.zzz"
        case .knee: return "figure.run"
        case .bodyFat: return "percent"
        case .leanMass: return "figure.strengthtraining.traditional"
        case .calories: return "flame.fill"
        case .water: return "drop.fill"
        }
    }

    var accent: Color {
        switch self {
        case .weight: return Theme.ember
        case .steps: return Theme.steel
        case .sleep: return Theme.violet
        case .knee: return Theme.rust
        case .bodyFat: return Theme.rust
        case .leanMass: return Theme.emberDeep
        case .calories: return Color(hex: 0xE0A22E)
        case .water: return Theme.water
        }
    }

    /// True for metrics where a rising trend is a bad sign (knee pain).
    var lowerIsBetter: Bool { self == .knee }

    /// Whether to draw the chart as bars (discrete daily counts) vs. a line.
    var usesBars: Bool { self == .steps }

    /// Fixed y-axis domain, where the scale is meaningful (knee is 0–10).
    var yDomain: ClosedRange<Double>? { self == .knee ? 0...10 : nil }

    func value(_ log: DailyLog) -> Double? {
        switch self {
        case .weight: return log.weightLb
        case .steps: return log.steps.map(Double.init)
        case .sleep: return log.sleepHours
        case .knee: return log.kneePainScore.map(Double.init)
        // No manual entry for these yet — Health (e.g. a synced smart scale)
        // is the only source.
        case .bodyFat, .leanMass: return nil
        // Calories are summed from MealLog + Health directly in `allPoints`,
        // not read off a single `DailyLog` field like the others.
        case .calories: return nil
        // Stored in liters (matches HealthKit + backups); displayed in oz,
        // same conversion Home's water chip and the Food tab's tracker use.
        case .water: return log.waterL.map { $0 * 33.814 }
        }
    }

    func format(_ v: Double) -> String {
        switch self {
        case .steps, .calories, .water: return Int(v.rounded()).formatted()
        case .knee: return String(Int(v.rounded()))
        case .weight, .sleep, .bodyFat, .leanMass: return String(format: "%.1f", v)
        }
    }
}

// MARK: - Range toggle

enum TrendRange: String, CaseIterable, Identifiable {
    case week, month
    var id: String { rawValue }
    var days: Int { self == .week ? 7 : 30 }
    var label: String { self == .week ? "Week" : "Month" }
}

private struct DayPoint: Identifiable {
    let date: Date
    let value: Double
    var id: Date { date }
}

// MARK: - Detail view

struct StatDetailView: View {
    let kind: StatKind
    /// The day tapped on Home — the "log / edit" shortcut targets this day.
    let day: Date

    @Environment(HealthKitManager.self) private var health
    @Query(sort: \DailyLog.date) private var dailyLogs: [DailyLog]
    @Query private var mealLogs: [MealLog]

    @State private var range: TrendRange = .week
    @State private var showLog = false
    @State private var sleepNights: [SleepNight] = []
    /// Historical Health values for the current `kind` (weight/steps), keyed by
    /// start-of-day, for days not covered by a manual `DailyLog` entry. Health
    /// retains this history indefinitely even though the app's own log doesn't.
    @State private var healthByDay: [Date: Double] = [:]

    private var cal: Calendar { Calendar.current }
    private var isToday: Bool { cal.isDateInToday(day) }

    // MARK: Data

    /// Every logged value over time, filled in with historical Health data
    /// (weight/steps/sleep) for any day that wasn't manually logged.
    private var allPoints: [DayPoint] {
        // Calories are additive — MealLog and Health (e.g. MyFitnessPal) each
        // cover different food, so both contribute to the same day's total,
        // rather than one being a fallback for the other.
        if kind == .calories {
            var byDay: [Date: Double] = [:]
            for log in mealLogs {
                byDay[cal.startOfDay(for: log.date), default: 0] += Double(log.kcal)
            }
            for (dayKey, v) in healthByDay {
                byDay[dayKey, default: 0] += v
            }
            return byDay.map { DayPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
        }
        var byDay: [Date: Double] = [:]
        for log in dailyLogs {
            if let v = kind.value(log) { byDay[cal.startOfDay(for: log.date)] = v }
        }
        let healthDays = kind == .sleep
            ? Dictionary(uniqueKeysWithValues: sleepNights.map { (cal.startOfDay(for: $0.date), $0.totalHours) })
            : healthByDay
        for (dayKey, v) in healthDays where byDay[dayKey] == nil {
            byDay[dayKey] = v
        }
        return byDay.map { DayPoint(date: $0.key, value: $0.value) }.sorted { $0.date < $1.date }
    }

    private var rangePoints: [DayPoint] {
        let start = cal.date(byAdding: .day, value: -(range.days - 1), to: cal.startOfDay(for: .now)) ?? .distantPast
        return allPoints.filter { $0.date >= start }
    }

    private var headline: Double? { allPoints.last?.value }

    /// Change between the two most recent logged values.
    private var delta: Double? {
        let last2 = allPoints.suffix(2)
        guard last2.count == 2, let a = last2.first?.value, let b = last2.last?.value else { return nil }
        return b - a
    }

    private var average: Double? {
        guard !rangePoints.isEmpty else { return nil }
        return rangePoints.reduce(0) { $0 + $1.value } / Double(rangePoints.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                headerCard
                rangePicker
                chartCard
                if kind == .sleep { sleepScoreCard }
                if !rangePoints.isEmpty { summaryCard }
                logButton
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .background(Theme.charcoal)
        .navigationTitle(kind.title)
        .navigationBarTitleDisplayMode(.inline)
        .blurredWhenPresenting(showLog)
        .sheet(isPresented: $showLog) { DailyLogSheet(day: day) }
        .task(id: range) {
            guard health.isConnected else { return }
            switch kind {
            case .sleep:
                sleepNights = await health.sleepNights(days: range.days)
            case .steps:
                let vals = await health.dailySteps(days: range.days)
                healthByDay = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), Double($0.value)) })
            case .weight:
                let vals = await health.dailyWeights(days: range.days)
                healthByDay = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), $0.value) })
            case .bodyFat:
                let vals = await health.dailyBodyFat(days: range.days)
                healthByDay = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), $0.value) })
            case .leanMass:
                let vals = await health.dailyLeanBodyMass(days: range.days)
                healthByDay = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), $0.value) })
            case .calories:
                let vals = await health.dailyDietaryTotals(days: range.days)
                healthByDay = Dictionary(uniqueKeysWithValues: vals.map { (cal.startOfDay(for: $0.date), Double($0.totals.kcal)) })
            case .knee, .water:
                break
            }
        }
    }

    // MARK: Sleep score (estimated from Apple Watch stages)

    @ViewBuilder private var sleepScoreCard: some View {
        SectionCard(title: "Sleep Score", subtitle: "Estimated from Apple Watch stages") {
            if let last = sleepNights.last {
                VStack(spacing: 16) {
                    HStack(spacing: 18) {
                        CircularRing(progress: Double(last.score) / 100, lineWidth: 10, arcColor: scoreColor(last.score)) {
                            VStack(spacing: 0) {
                                Text("\(last.score)")
                                    .font(Theme.pixel(30))
                                    .foregroundStyle(Theme.chalk)
                                Text(scoreLabel(last.score))
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(scoreColor(last.score))
                            }
                        }
                        .frame(width: 96, height: 96)
                        VStack(spacing: 8) {
                            breakdownRow("Duration", String(format: "%.1f h", last.totalHours))
                            breakdownRow("Deep", "\(Int((last.deepPct * 100).rounded()))%")
                            breakdownRow("REM", "\(Int((last.remPct * 100).rounded()))%")
                        }
                    }
                    if sleepNights.count > 1 { sleepScoreChart }
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
                Text("No staged sleep data from your Watch in this range.")
                    .font(.system(size: 13))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
    }

    private var sleepScoreChart: some View {
        Chart(sleepNights) { n in
            BarMark(
                x: .value("Day", n.date, unit: .day),
                y: .value("Score", n.score)
            )
            .foregroundStyle(scoreColor(n.score).gradient)
            .cornerRadius(3)
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: range == .week ? 1 : 7)) { _ in
                AxisGridLine().foregroundStyle(Theme.hairline)
                AxisValueLabel(
                    format: range == .week
                        ? Date.FormatStyle.dateTime.weekday(.narrow)
                        : Date.FormatStyle.dateTime.month(.abbreviated).day()
                )
                .foregroundStyle(Theme.chalkDim)
            }
        }
        .chartYAxis {
            AxisMarks(values: [0, 50, 100]) { _ in
                AxisGridLine().foregroundStyle(Theme.hairline)
                AxisValueLabel().foregroundStyle(Theme.chalkDim)
            }
        }
        .frame(height: 130)
    }

    private func breakdownRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 13)).foregroundStyle(Theme.chalkDim)
            Spacer()
            Text(value).font(Theme.mono(13, weight: .semibold)).foregroundStyle(Theme.chalk)
        }
    }

    private func scoreLabel(_ s: Int) -> String {
        s >= 85 ? "HIGH" : s >= 70 ? "GOOD" : s >= 50 ? "FAIR" : "LOW"
    }
    /// Flat purple regardless of score — matches Home's "purple-only" Sleep
    /// Score card rather than grading quality through color.
    private func scoreColor(_ s: Int) -> Color { Theme.violet }

    // MARK: Header

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: kind.icon)
                    .font(.system(size: 15))
                    .foregroundStyle(kind.accent)
                Text("Current")
                    .font(.system(size: 12, weight: .semibold))
                    .tracking(0.5)
                    .textCase(.uppercase)
                    .foregroundStyle(Theme.chalkDim)
                Spacer()
                deltaChip
            }
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(headline.map(kind.format) ?? "—")
                    .font(Theme.pixel(48))
                    .foregroundStyle(Theme.chalk)
                Text(kind.unit)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    @ViewBuilder private var deltaChip: some View {
        if let d = delta, abs(d) > 0.0001 {
            let rising = d > 0
            let good = rising ? !kind.lowerIsBetter : kind.lowerIsBetter
            let color = kind.lowerIsBetter || kind == .weight ? (good ? Theme.moss : Theme.rust) : Theme.chalkDim
            HStack(spacing: 4) {
                Image(systemName: rising ? "arrow.up.right" : "arrow.down.right")
                    .font(.system(size: 11, weight: .bold))
                Text(kind.format(abs(d)) + (kind.unit == "/10" ? "" : kind.unit))
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(color)
            .padding(.vertical, 4)
            .padding(.horizontal, 9)
            .background(color.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    // MARK: Range

    private var rangePicker: some View {
        HStack(spacing: 6) {
            ForEach(TrendRange.allCases) { r in
                Button { withAnimation(.easeInOut(duration: 0.15)) { range = r } } label: {
                    Text(r.label)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(range == r ? Color(hex: 0x151515) : Theme.chalkDim)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 9)
                        .background(range == r ? kind.accent : Theme.iron)
                        .overlay(
                            RoundedRectangle(cornerRadius: Theme.fieldRadius)
                                .stroke(range == r ? Color.clear : Theme.hairline, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: Chart

    private var chartCard: some View {
        SectionCard(title: "Trend", subtitle: range == .week ? "Last 7 days" : "Last 30 days") {
            if rangePoints.isEmpty {
                emptyState
            } else {
                chart
            }
        }
    }

    private var chart: some View {
        Chart {
            ForEach(rangePoints) { p in
                if kind.usesBars {
                    BarMark(
                        x: .value("Day", p.date, unit: .day),
                        y: .value(kind.title, p.value)
                    )
                    .foregroundStyle(kind.accent.gradient)
                    .cornerRadius(3)
                } else {
                    AreaMark(
                        x: .value("Day", p.date, unit: .day),
                        y: .value(kind.title, p.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [kind.accent.opacity(0.35), kind.accent.opacity(0.02)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    LineMark(
                        x: .value("Day", p.date, unit: .day),
                        y: .value(kind.title, p.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(kind.accent)
                    .lineStyle(StrokeStyle(lineWidth: 2.5))
                    .symbol {
                        Circle().fill(kind.accent).frame(width: 6, height: 6)
                    }
                }
            }
            if let avg = average {
                RuleMark(y: .value("Average", avg))
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    .foregroundStyle(Theme.chalkDim.opacity(0.7))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("avg \(kind.format(avg))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(Theme.chalkDim)
                    }
            }
        }
        .chartYScale(domain: yScaleDomain)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: range == .week ? 1 : 7)) { _ in
                AxisGridLine().foregroundStyle(Theme.hairline)
                AxisValueLabel(
                    format: range == .week
                        ? Date.FormatStyle.dateTime.weekday(.narrow)
                        : Date.FormatStyle.dateTime.month(.abbreviated).day()
                )
                .foregroundStyle(Theme.chalkDim)
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine().foregroundStyle(Theme.hairline)
                AxisValueLabel().foregroundStyle(Theme.chalkDim)
            }
        }
        .frame(height: 210)
    }

    /// Knee uses a fixed 0–10 scale; everything else auto-scales with padding.
    private var yScaleDomain: ClosedRange<Double> {
        if let fixed = kind.yDomain { return fixed }
        let values = rangePoints.map(\.value)
        let lo = values.min() ?? 0
        let hi = values.max() ?? 1
        let pad = max((hi - lo) * 0.15, hi == lo ? max(hi * 0.05, 1) : 0.5)
        return (lo - pad)...(hi + pad)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 30))
                .foregroundStyle(Theme.chalkDim.opacity(0.5))
            Text("No \(kind.title.lowercased()) logged yet")
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    // MARK: Summary

    private var summaryCard: some View {
        let values = rangePoints.map(\.value)
        return SectionCard(title: "Summary", subtitle: range == .week ? "This week" : "This month") {
            HStack(spacing: 10) {
                StatTile(label: "Average", value: average.map(kind.format) ?? "—", accent: kind.accent)
                StatTile(label: "Low", value: values.min().map(kind.format) ?? "—")
                StatTile(label: "High", value: values.max().map(kind.format) ?? "—")
            }
        }
    }

    // MARK: Log shortcut

    private var logButton: some View {
        Button { showLog = true } label: {
            HStack(spacing: 8) {
                Image(systemName: "square.and.pencil").font(.system(size: 14, weight: .bold))
                Text(isToday ? "Log / edit today" : "Log / edit \(day.formatted(.dateTime.month().day()))")
            }
        }
        .buttonStyle(SteelButtonStyle())
        .padding(.top, 4)
    }
}
