//
//  NotificationsSettingsView.swift
//  RecompCoach
//
//  Pushed from Profile's "Notifications" row. A master on/off switch plus
//  individual toggles for every trigger in NotificationsManager. Any change
//  clears all pending local notifications and re-derives them from the new
//  toggle states via `rescheduleAll`.
//

import SwiftUI
import SwiftData

struct NotificationsSettingsView: View {
    @Environment(NotificationsManager.self) private var notifications
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]

    private var profile: UserProfile? { profiles.first }
    private var cal: Calendar { Calendar.current }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                SectionCard(
                    title: "Notifications",
                    subtitle: notifications.isAuthorized ? nil : "Enable notifications from the banner on Home first."
                ) {
                    Toggle(isOn: binding(\.masterEnabled)) {
                        Text("All Notifications")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(Theme.chalk)
                    }
                    .tint(Theme.ember)
                }

                if notifications.isAuthorized {
                    let dimmed = !notifications.masterEnabled

                    SectionCard(title: "Reminders", subtitle: nil) {
                        VStack(spacing: 10) {
                            toggleRow("Workout day reminder", "Morning of each scheduled session", binding(\.workoutRemindersEnabled))
                            divider
                            toggleRow("Evening log reminder", "If today isn't logged yet by 8:30pm", binding(\.eveningLogReminderEnabled))
                            divider
                            toggleRow("Monthly progress photo", "Same day of month you started, at 9am", binding(\.progressPhotoReminderEnabled))
                        }
                    }
                    .disabled(dimmed)
                    .opacity(dimmed ? 0.4 : 1)

                    SectionCard(title: "Program Schedule", subtitle: nil) {
                        VStack(spacing: 10) {
                            toggleRow("Phase transitions", "New phase starts (e.g. Week 5)", binding(\.phaseTransitionsEnabled))
                            divider
                            toggleRow("Deload weeks", "Framing for each lighter week", binding(\.deloadWeeksEnabled))
                            divider
                            toggleRow("Assessment days", "Every 4 weeks (Week 4, 8, 12…)", binding(\.assessmentDaysEnabled))
                            divider
                            toggleRow("Halfway & completion", "Week 26 and Week 52 milestones", binding(\.programMilestonesEnabled))
                        }
                    }
                    .disabled(dimmed)
                    .opacity(dimmed ? 0.4 : 1)

                    SectionCard(title: "Training Feedback", subtitle: nil) {
                        VStack(spacing: 10) {
                            toggleRow("Missed sessions", "2+ scheduled workouts in a row skipped", binding(\.missedSessionsEnabled))
                            divider
                            toggleRow("Weekly summary", "Sessions, sleep, weight, knee trend", binding(\.weeklySummaryEnabled))
                            divider
                            toggleRow("Logging streaks", "Every 7-day daily-log streak", binding(\.streaksEnabled))
                            divider
                            toggleRow("Knee pain flag", "Knee pain logged at 5/10 or higher", binding(\.kneeFlagEnabled))
                            divider
                            toggleRow("New PRs", "A new top weight/rep on a lift", binding(\.prsEnabled))
                            divider
                            toggleRow("Plateau alerts", "Same weight × reps 3 sessions running", binding(\.plateausEnabled))
                        }
                    }
                    .disabled(dimmed)
                    .opacity(dimmed ? 0.4 : 1)
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var divider: some View {
        Divider().overlay(Theme.hairline)
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

    /// A binding to one of `NotificationsManager`'s toggle properties that
    /// re-derives all pending notifications on every change.
    private func binding(_ keyPath: ReferenceWritableKeyPath<NotificationsManager, Bool>) -> Binding<Bool> {
        Binding(
            get: { notifications[keyPath: keyPath] },
            set: { newValue in
                notifications[keyPath: keyPath] = newValue
                guard let p = profile else { return }
                let loggedToday = dailyLogs.contains { cal.isDateInToday($0.date) }
                notifications.rescheduleAll(startDate: p.startDate, loggedToday: loggedToday)
            }
        )
    }
}
