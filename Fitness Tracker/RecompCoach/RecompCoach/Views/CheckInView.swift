//
//  CheckInView.swift
//  RecompCoach
//
//  Weekly check-in. "Auto-fill from logs" derives weight change, average sleep,
//  and sessions completed from the daily logs and workout sessions in that
//  program week — the same computation the HTML prototype did.
//

import SwiftUI
import SwiftData

struct CheckInView: View {
    @Environment(\.modelContext) private var context
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]
    @Query private var sessions: [WorkoutSession]
    @Query private var checkIns: [WeeklyCheckIn]

    @State private var week = 1
    @State private var weightChange = ""
    @State private var avgSleep = ""
    @State private var sessionsCompleted = ""
    @State private var kneeTrend: KneeTrend = .same
    @State private var feltHard = ""
    @State private var feltGood = ""
    @State private var toast: String?

    private var profile: UserProfile? { profiles.first }
    private var cal: Calendar { Calendar.current }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                formCard
                pastCheckInsCard
            }
            .padding(16)
        }
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .overlay(alignment: .bottom) { ToastView(text: toast) }
        .onAppear {
            if let p = profile { week = ProgramClock.weekNumber(start: p.startDate) }
            loadForWeek()
        }
        .onChange(of: week) { _, _ in loadForWeek() }
    }

    private var formCard: some View {
        SectionCard(title: "Weekly Check-in", subtitle: "Do this once a week, same day each time.") {
            VStack(spacing: 12) {
                HStack(alignment: .bottom, spacing: 12) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Week number")
                            .font(.system(size: 12)).foregroundStyle(Theme.chalkDim)
                        Stepper(value: $week, in: 1...52) {
                            Text("Week \(week)").font(Theme.mono(15)).foregroundStyle(Theme.chalk)
                        }
                    }
                    Button("Auto-fill", action: autofill)
                        .buttonStyle(GhostButtonStyle())
                }
                HStack(spacing: 12) {
                    LabeledField(label: "Weight change (lb, ±)", placeholder: "-0.6", keyboard: .numbersAndPunctuation, text: $weightChange)
                    LabeledField(label: "Avg sleep (hrs)", placeholder: "7.0", keyboard: .decimalPad, text: $avgSleep)
                }
                HStack(spacing: 12) {
                    LabeledField(label: "Sessions (of 4)", placeholder: "4", keyboard: .numberPad, text: $sessionsCompleted)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Knee pain trend")
                            .font(.system(size: 12)).foregroundStyle(Theme.chalkDim)
                        Menu {
                            Picker("Knee trend", selection: $kneeTrend) {
                                ForEach(KneeTrend.allCases) { Text($0.label).tag($0) }
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Text(kneeTrend.label)
                                    .font(.system(size: 14))
                                    .foregroundStyle(Theme.chalk)
                                    .lineLimit(1)
                                Spacer(minLength: 0)
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
                }
                NotesField(label: "One thing that felt hard", text: $feltHard)
                NotesField(label: "One thing that felt good", text: $feltGood)
                Button("Save check-in", action: save)
                    .buttonStyle(SteelButtonStyle())
            }
        }
    }

    private var pastCheckInsCard: some View {
        SectionCard(title: "Past Check-ins", subtitle: nil) {
            let sorted = checkIns.sorted { $0.weekNumber > $1.weekNumber }
            if sorted.isEmpty {
                Text("No check-ins yet — save one to see it here.")
                    .font(.system(size: 13)).foregroundStyle(Theme.chalkDim)
                    .frame(maxWidth: .infinity).padding(.vertical, 12)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(sorted.enumerated()), id: \.element.weekNumber) { idx, c in
                        HStack {
                            Text("Week \(c.weekNumber)")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Theme.chalk)
                            Spacer()
                            Text(summary(for: c))
                                .font(Theme.mono(11))
                                .foregroundStyle(Theme.chalkDim)
                        }
                        .padding(.vertical, 10)
                        if idx < sorted.count - 1 { Divider().overlay(Theme.hairline) }
                    }
                }
            }
        }
    }

    private func summary(for c: WeeklyCheckIn) -> String {
        var parts: [String] = []
        if let w = c.weightChangeLb { parts.append("\(w > 0 ? "+" : "")\(trimDecimal(w))lb") }
        if let s = c.sessionsCompleted { parts.append("\(s)/4") }
        parts.append(c.kneeTrend == .worse ? "knee↓" : c.kneeTrend == .improving ? "knee↑" : "knee=")
        return parts.joined(separator: " · ")
    }

    // MARK: Logic

    private func autofill() {
        guard let p = profile else { return }
        let days = ProgramClock.days(inWeek: week, start: p.startDate)
        guard let weekStart = days.first, let weekEnd = days.last else { return }

        let inRange: (Date) -> Bool = { d in
            let day = cal.startOfDay(for: d)
            return day >= weekStart && day <= weekEnd
        }

        // Weight change + avg sleep from daily logs.
        let weekLogs = dailyLogs.filter { inRange($0.date) }.sorted { $0.date < $1.date }
        let weights = weekLogs.compactMap { $0.weightLb }
        if let first = weights.first, let last = weights.last, weights.count >= 2 {
            weightChange = trimDecimal(last - first)
        }
        let sleeps = weekLogs.compactMap { $0.sleepHours }
        if !sleeps.isEmpty {
            avgSleep = String(format: "%.1f", sleeps.reduce(0, +) / Double(sleeps.count))
        }

        // Sessions from workout logs.
        let sessionCount = sessions.filter { inRange($0.date) }.count
        sessionsCompleted = String(sessionCount)

        showToast("Auto-filled from logs")
    }

    private func existingCheckIn() -> WeeklyCheckIn? {
        checkIns.first { $0.weekNumber == week }
    }

    private func loadForWeek() {
        guard let c = existingCheckIn() else {
            weightChange = ""; avgSleep = ""; sessionsCompleted = ""
            kneeTrend = .same; feltHard = ""; feltGood = ""
            return
        }
        weightChange = c.weightChangeLb.fieldText
        avgSleep = c.avgSleepHours.fieldText
        sessionsCompleted = c.sessionsCompleted.fieldText
        kneeTrend = c.kneeTrend
        feltHard = c.feltHard
        feltGood = c.feltGood
    }

    private func save() {
        let c = existingCheckIn() ?? {
            let new = WeeklyCheckIn(weekNumber: week)
            context.insert(new)
            return new
        }()
        c.weightChangeLb = weightChange.optDouble
        c.avgSleepHours = avgSleep.optDouble
        c.sessionsCompleted = sessionsCompleted.optInt
        c.kneeTrend = kneeTrend
        c.feltHard = feltHard
        c.feltGood = feltGood
        try? context.save()
        showToast("Check-in saved")
    }

    private func showToast(_ msg: String) {
        withAnimation { toast = msg }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation { toast = nil }
        }
    }
}
