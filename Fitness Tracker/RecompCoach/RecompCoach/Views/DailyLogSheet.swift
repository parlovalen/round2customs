//
//  DailyLogSheet.swift
//  RecompCoach
//
//  The full daily-log editor, presented as a sheet from the Home dashboard.
//  Upserts the DailyLog for a given day (weight, nutrition, sleep, recovery).
//

import SwiftUI
import SwiftData

struct DailyLogSheet: View {
    let day: Date

    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var dailyLogs: [DailyLog]

    @State private var weight = ""
    @State private var sleep = ""
    @State private var calories = ""
    @State private var protein = ""
    @State private var water = ""
    @State private var steps = ""
    @State private var mood = ""
    @State private var soreness = ""
    @State private var knee = ""
    @State private var notes = ""

    private var cal: Calendar { Calendar.current }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    SectionCard(title: "Daily Log", subtitle: "Weight, nutrition, sleep, recovery.") {
                        VStack(spacing: 12) {
                            HStack(spacing: 12) {
                                LabeledField(label: "Body weight (lb)", placeholder: "187.0", keyboard: .decimalPad, text: $weight)
                                LabeledField(label: "Sleep (hrs)", placeholder: "7.0", keyboard: .decimalPad, text: $sleep)
                            }
                            HStack(spacing: 12) {
                                LabeledField(label: "Calories", placeholder: "2600", keyboard: .numberPad, text: $calories)
                                LabeledField(label: "Protein (g)", placeholder: "185", keyboard: .numberPad, text: $protein)
                                LabeledField(label: "Water (L)", placeholder: "3.8", keyboard: .decimalPad, text: $water)
                            }
                            HStack(spacing: 12) {
                                LabeledField(label: "Steps", placeholder: "8000", keyboard: .numberPad, text: $steps)
                                LabeledField(label: "Mood (1–5)", placeholder: "4", keyboard: .numberPad, text: $mood)
                                LabeledField(label: "Soreness (1–5)", placeholder: "2", keyboard: .numberPad, text: $soreness)
                            }
                            LabeledField(label: "Knee pain today (0–10)", placeholder: "1", keyboard: .numberPad, text: $knee)
                            NotesField(label: "Notes", placeholder: "Anything worth remembering…", text: $notes)
                        }
                    }
                }
                .padding(16)
            }
            .background(Theme.charcoal)
            .scrollDismissesKeyboard(.interactively)
            .dismissKeyboardOnTap()
            .navigationTitle(day.formatted(.dateTime.weekday(.wide).month().day()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save(); dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onAppear(perform: load)
        }
        .presentationDetents([.large])
    }

    private func existingLog() -> DailyLog? {
        let d = cal.startOfDay(for: day)
        return dailyLogs.first { cal.isDate($0.date, inSameDayAs: d) }
    }

    private func load() {
        guard let log = existingLog() else { return }
        weight = log.weightLb.fieldText
        sleep = log.sleepHours.fieldText
        calories = log.calories.fieldText
        protein = log.proteinG.fieldText
        water = log.waterL.fieldText
        steps = log.steps.fieldText
        mood = log.moodScore.fieldText
        soreness = log.sorenessScore.fieldText
        knee = log.kneePainScore.fieldText
        notes = log.notes
    }

    private func save() {
        let d = cal.startOfDay(for: day)
        let log = existingLog() ?? {
            let new = DailyLog(date: d)
            context.insert(new)
            return new
        }()
        log.weightLb = weight.optDouble
        log.sleepHours = sleep.optDouble
        log.calories = calories.optInt
        log.proteinG = protein.optInt
        log.waterL = water.optDouble
        log.steps = steps.optInt
        log.moodScore = mood.optInt
        log.sorenessScore = soreness.optInt
        log.kneePainScore = knee.optInt
        log.notes = notes
        try? context.save()
        exportToHealth(log, day: d)

        // Fetched fresh (not the view's `@Query` snapshot) so the streak count
        // includes the row just saved, regardless of when SwiftUI re-runs the query.
        let allLogs = (try? context.fetch(FetchDescriptor<DailyLog>())) ?? dailyLogs
        NotificationsManager.shared.checkKneePainFlag(day: d, score: log.kneePainScore)
        NotificationsManager.shared.checkStreak(dailyLogs: allLogs)
        if cal.isDateInToday(d) {
            NotificationsManager.shared.scheduleEveningLogReminder(alreadyLoggedToday: true)
        }
    }

    /// Push the day's weight + nutrition to Apple Health (best-effort).
    private func exportToHealth(_ log: DailyLog, day: Date) {
        let hk = HealthKitManager.shared
        guard hk.isConnected else { return }
        Task {
            if let w = log.weightLb { await hk.saveBodyMass(lb: w, date: day) }
            await hk.saveNutrition(
                kcal: log.calories, proteinG: log.proteinG, carbG: log.carbG,
                fatG: log.fatG, waterL: log.waterL, date: day
            )
        }
    }
}
