//
//  IntegrationsView.swift
//  RecompCoach
//
//  Pushed from Profile's "Integrations" row. Lists connected apps (currently
//  just Apple Health) and, once connected, per-category toggles for exactly
//  what data moves in each direction — these gate the actual HealthKit calls
//  in HealthKitManager, not just the UI.
//

import SwiftUI

struct IntegrationsView: View {
    @Environment(HealthKitManager.self) private var health

    var body: some View {
        @Bindable var health = health
        ScrollView {
            VStack(spacing: 14) {
                SectionCard(
                    title: "Apple Health",
                    subtitle: health.isConnected ? "Connected" : "Reads your dashboard metrics; writes back logged weight, nutrition, and workouts."
                ) {
                    if !health.isConnected {
                        Button("Connect Apple Health") {
                            Task { await health.requestAuthorization() }
                        }
                        .buttonStyle(SteelButtonStyle())
                    } else {
                        VStack(spacing: 14) {
                            VStack(spacing: 10) {
                                groupLabel("Read from Health")
                                toggleRow("Weight & body composition", "Weight, body fat %, lean mass", $health.syncReadWeight)
                                divider
                                toggleRow("Activity", "Steps, active energy, exercise minutes, stand hours", $health.syncReadActivity)
                                divider
                                toggleRow("Heart & fitness", "Resting heart rate, HRV, VO2 max", $health.syncReadHeart)
                                divider
                                toggleRow("Sleep", "Sleep stages, used for the sleep score", $health.syncReadSleep)
                                divider
                                toggleRow("Nutrition", "Picks up food logged in other apps (e.g. MyFitnessPal)", $health.syncReadNutrition)
                            }
                            Divider().overlay(Theme.hairline)
                            VStack(spacing: 10) {
                                groupLabel("Write to Health")
                                toggleRow("Body weight", "Saved when you log a daily weight", $health.syncWriteWeight)
                                divider
                                toggleRow("Nutrition & water", "Saved when you log meals or water", $health.syncWriteNutrition)
                                divider
                                toggleRow("Workouts", "Saved when you finish a logged session", $health.syncWriteWorkouts)
                            }
                        }
                    }
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle("Integrations")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var divider: some View {
        Divider().overlay(Theme.hairline)
    }

    private func groupLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold))
            .tracking(0.4)
            .foregroundStyle(Theme.chalkDim)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func toggleRow(_ title: String, _ subtitle: String, _ isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Theme.chalk)
                Text(subtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .tint(Theme.ember)
    }
}
