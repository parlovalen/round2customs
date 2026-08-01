//
//  HistoryView.swift
//  RecompCoach
//
//  Trends (weight, knee pain) via Swift Charts, plus a recent-entries feed
//  combining daily logs and workouts. Backup/restore and reset moved to
//  Profile > Backup & Restore.
//

import SwiftUI
import SwiftData
import Charts

struct HistoryView: View {
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]
    @Query private var sessions: [WorkoutSession]

    private var profile: UserProfile? { profiles.first }

    @State private var showCheckIn = false
    @State private var showEducation = false

    private var cal: Calendar { Calendar.current }

    private var currentWeek: Int {
        guard let p = profile else { return 1 }
        return ProgramClock.weekNumber(start: p.startDate)
    }
    private var currentCurriculumMonth: Int { EducationCatalog.currentMonth(forWeek: currentWeek) }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                checkInCard
                learnCard
                weightCard
                kneeCard
                recentCard
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .blurredWhenPresenting(showCheckIn || showEducation)
        .sheet(isPresented: $showCheckIn) {
            NavigationStack {
                ZStack {
                    GlowBackground()
                    CheckInView()
                }
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showCheckIn = false }
                    }
                }
            }
        }
        .sheet(isPresented: $showEducation) {
            NavigationStack {
                ZStack {
                    GlowBackground()
                    EducationView(currentMonth: currentCurriculumMonth)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") { showEducation = false }
                    }
                }
            }
        }
    }

    /// Entry point for the weekly check-in (its own tab was replaced by Food).
    private var checkInCard: some View {
        Button { showCheckIn = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.ember)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Weekly Check-in")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Text("Log this week's weight, sleep, and knee trend")
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

    /// Entry point for the education curriculum.
    private var learnCard: some View {
        Button { showEducation = true } label: {
            HStack(spacing: 12) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.violet)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Learn")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Text("Month \(currentCurriculumMonth): \(EducationCatalog.month(currentCurriculumMonth)?.topic ?? "")")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.chalkDim)
                        .lineLimit(2)
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

    // MARK: Weight

    private var weightPoints: [(date: Date, value: Double)] {
        dailyLogs.compactMap { log in log.weightLb.map { (log.date, $0) } }
            .sorted { $0.date < $1.date }
    }

    private var weightCard: some View {
        SectionCard(title: "Weight Trend", subtitle: nil) {
            if weightPoints.count < 2 {
                emptyChart("Log body weight on 2+ days to see the trend.", icon: "chart.line.uptrend.xyaxis")
            } else {
                Chart(weightPoints, id: \.date) { p in
                    LineMark(x: .value("Date", p.date), y: .value("Weight", p.value))
                        .foregroundStyle(Theme.steel)
                        .interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Date", p.date), y: .value("Weight", p.value))
                        .foregroundStyle(Theme.steel.opacity(0.15))
                        .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: .automatic(includesZero: false))
                .frame(height: 200)
                .styledAxes()
            }
        }
    }

    // MARK: Knee

    private var kneePoints: [(date: Date, value: Double)] {
        var pts: [(Date, Double)] = []
        for log in dailyLogs { if let k = log.kneePainScore { pts.append((log.date, Double(k))) } }
        for s in sessions { if let k = s.kneePainNextMorning { pts.append((s.date, Double(k))) } }
        return pts.sorted { $0.0 < $1.0 }.map { (date: $0.0, value: $0.1) }
    }

    private var kneeCard: some View {
        SectionCard(title: "Knee Pain Trend", subtitle: "0 = none · 10 = severe") {
            if kneePoints.count < 2 {
                emptyChart("Log knee pain to track how the tendon responds.", icon: "waveform.path.ecg")
            } else {
                Chart(kneePoints, id: \.date) { p in
                    LineMark(x: .value("Date", p.date), y: .value("Pain", p.value))
                        .foregroundStyle(Theme.rust)
                        .interpolationMethod(.catmullRom)
                    AreaMark(x: .value("Date", p.date), y: .value("Pain", p.value))
                        .foregroundStyle(Theme.rust.opacity(0.15))
                        .interpolationMethod(.catmullRom)
                }
                .chartYScale(domain: 0...10)
                .frame(height: 200)
                .styledAxes()
            }
        }
    }

    // MARK: Recent entries

    private struct FeedItem: Identifiable {
        let id = UUID()
        let kind: String
        let date: Date
        let meta: String
    }

    private var feed: [FeedItem] {
        var items: [FeedItem] = []
        for log in dailyLogs {
            let meta = "\(log.calories.map(String.init) ?? "—") kcal · "
                + "\(log.proteinG.map(String.init) ?? "—")g protein · "
                + "knee \(log.kneePainScore.map(String.init) ?? "—")"
            items.append(FeedItem(kind: "Daily", date: log.date, meta: meta))
        }
        for s in sessions {
            let meta = "\(s.workoutType?.displayName ?? "Workout") · knee \(s.kneePainDuring.map(String.init) ?? "—")"
            items.append(FeedItem(kind: "Workout", date: s.date, meta: meta))
        }
        return items.sorted { $0.date > $1.date }.prefix(15).map { $0 }
    }

    private var recentCard: some View {
        SectionCard(title: "Recent Entries", subtitle: nil) {
            if feed.isEmpty {
                Text("No entries yet — log a day or a workout to see it here.")
                    .font(.system(size: 13)).foregroundStyle(Theme.chalkDim)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(feed.enumerated()), id: \.element.id) { idx, item in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.kind)
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(item.kind == "Workout" ? Theme.steel : Theme.chalk)
                                Text(item.meta)
                                    .font(.system(size: 11.5))
                                    .foregroundStyle(Theme.chalkDim)
                            }
                            Spacer()
                            Text(item.date, format: .dateTime.month(.abbreviated).day())
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.chalkDim)
                        }
                        .padding(.vertical, 10)
                        if idx < feed.count - 1 { Divider().overlay(Theme.hairline) }
                    }
                }
            }
        }
    }

    // MARK: Helpers

    private func emptyChart(_ msg: String, icon: String = "chart.xyaxis.line") -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.chalkDim.opacity(0.5))
            Text(msg)
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.vertical, 8)
    }
}

// MARK: - Chart axis styling

private extension View {
    func styledAxes() -> some View {
        self
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Theme.hairline)
                    AxisValueLabel().foregroundStyle(Theme.chalkDim)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Theme.hairline)
                    AxisValueLabel().foregroundStyle(Theme.chalkDim)
                }
            }
    }
}
