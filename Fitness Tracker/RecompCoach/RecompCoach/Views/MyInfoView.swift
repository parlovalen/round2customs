//
//  MyInfoView.swift
//  RecompCoach
//
//  Pushed from Profile's "My Info" row. The physical/goal/nutrition fields
//  that used to live directly on the Profile screen (About You + Nutrition
//  Targets) — unchanged content, just its own screen now.
//

import SwiftUI
import SwiftData

struct MyInfoView: View {
    @Environment(\.modelContext) private var context
    @Environment(NotificationsManager.self) private var notifications
    @Query private var profiles: [UserProfile]

    @State private var name = ""
    @State private var age = ""
    @State private var heightCm = ""
    @State private var startWeightLb = ""
    @State private var biologicalSex = "male"
    @State private var bodyFatPercent = ""
    @State private var goal = ""
    @State private var trainingDaysPerWeek = ""
    @State private var startDate = Date()
    @State private var dailyCalorieTarget = ""
    @State private var proteinTargetG = ""
    @State private var carbTargetG = ""
    @State private var fatTargetG = ""
    @State private var waterTargetL = ""

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SectionCard(title: "About You", subtitle: nil) {
                    VStack(spacing: 12) {
                        LabeledField(label: "Name", placeholder: "Your name", text: $name)
                        HStack(spacing: 12) {
                            LabeledField(label: "Age", placeholder: "42", keyboard: .numberPad, text: $age)
                            LabeledField(label: "Height (cm)", placeholder: "180.3", keyboard: .decimalPad, text: $heightCm)
                        }
                        HStack(spacing: 12) {
                            LabeledField(label: "Weight (lb)", placeholder: "187", keyboard: .decimalPad, text: $startWeightLb)
                            LabeledField(label: "Body fat (%)", placeholder: "22", keyboard: .decimalPad, text: $bodyFatPercent)
                        }
                        sexPicker
                        LabeledField(label: "Goal", placeholder: "recomposition", text: $goal)
                        LabeledField(label: "Training days/week", placeholder: "4", keyboard: .numberPad, text: $trainingDaysPerWeek)
                        startDateRow
                    }
                }
                SectionCard(title: "Nutrition Targets", subtitle: "Drives the progress bars on the Food tab.") {
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            LabeledField(label: "Calories", placeholder: "2600", keyboard: .numberPad, text: $dailyCalorieTarget)
                            LabeledField(label: "Protein (g)", placeholder: "185", keyboard: .numberPad, text: $proteinTargetG)
                        }
                        HStack(spacing: 12) {
                            LabeledField(label: "Carbs (g)", placeholder: "285", keyboard: .numberPad, text: $carbTargetG)
                            LabeledField(label: "Fat (g)", placeholder: "80", keyboard: .numberPad, text: $fatTargetG)
                            LabeledField(label: "Water (L)", placeholder: "3.75", keyboard: .decimalPad, text: $waterTargetL)
                        }
                    }
                }
                SectionCard(title: "Progress Photos", subtitle: "Visual change the scale doesn't show.") {
                    ProgressPhotosSection()
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .scrollDismissesKeyboard(.interactively)
        .dismissKeyboardOnTap()
        .navigationTitle("My Info")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save", action: save)
                    .fontWeight(.semibold)
            }
        }
        .onAppear(perform: load)
    }

    // MARK: Biological sex

    private var sexPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Biological sex")
                .font(.system(size: 12))
                .foregroundStyle(Theme.chalkDim)
            Menu {
                Picker("Biological sex", selection: $biologicalSex) {
                    Text("Male").tag("male")
                    Text("Female").tag("female")
                }
            } label: {
                HStack {
                    Text(biologicalSex.capitalized)
                        .font(.system(size: 14))
                        .foregroundStyle(Theme.chalk)
                    Spacer()
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(Theme.chalkDim)
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 11)
                .background(Theme.iron2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .stroke(Theme.hairline, lineWidth: 1)
                )
            }
        }
    }

    // MARK: Program start date

    private var startDateRow: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Program start date")
                .font(.system(size: 12))
                .foregroundStyle(Theme.chalkDim)
            Text("Changing this shifts every week/phase calculation in the app.")
                .font(.system(size: 10.5))
                .foregroundStyle(Theme.chalkDim.opacity(0.8))
            DatePicker("", selection: $startDate, displayedComponents: .date)
                .labelsHidden()
                .colorScheme(.dark)
                .tint(Theme.ember)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: Load / save

    private func load() {
        guard let p = profile else { return }
        name = p.name
        age = String(p.age)
        heightCm = String(p.heightCm)
        startWeightLb = String(p.startWeightLb)
        biologicalSex = p.biologicalSex
        bodyFatPercent = String(p.bodyFatEstimatePercent)
        goal = p.goal
        trainingDaysPerWeek = String(p.trainingDaysPerWeek)
        startDate = p.startDate
        dailyCalorieTarget = String(p.dailyCalorieTarget)
        proteinTargetG = String(p.proteinTargetG)
        carbTargetG = String(p.carbTargetG)
        fatTargetG = String(p.fatTargetG)
        waterTargetL = String(p.waterTargetL)
    }

    private func save() {
        let p = profile ?? {
            let new = UserProfile()
            context.insert(new)
            return new
        }()
        p.name = name
        if let v = Int(age) { p.age = v }
        if let v = Double(heightCm) { p.heightCm = v }
        if let v = Double(startWeightLb) { p.startWeightLb = v }
        p.biologicalSex = biologicalSex
        if let v = Double(bodyFatPercent) { p.bodyFatEstimatePercent = v }
        p.goal = goal
        if let v = Int(trainingDaysPerWeek) { p.trainingDaysPerWeek = v }
        p.startDate = startDate
        if let v = Int(dailyCalorieTarget) { p.dailyCalorieTarget = v }
        if let v = Int(proteinTargetG) { p.proteinTargetG = v }
        if let v = Int(carbTargetG) { p.carbTargetG = v }
        if let v = Int(fatTargetG) { p.fatTargetG = v }
        if let v = Double(waterTargetL) { p.waterTargetL = v }
        try? context.save()

        // startDate drives every week/phase calculation, so a change here
        // needs every scheduled notification re-derived from the new date.
        if notifications.isAuthorized {
            notifications.scheduleProgramMilestones(startDate: p.startDate)
            notifications.scheduleWorkoutDayReminders(startDate: p.startDate)
            notifications.scheduleProgressPhotoReminder(startDate: p.startDate)
        }
    }
}
