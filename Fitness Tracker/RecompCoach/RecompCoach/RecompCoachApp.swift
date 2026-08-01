//
//  RecompCoachApp.swift
//  RecompCoach
//
//  App entry point. Configures an on-device SwiftData container and ensures a
//  UserProfile exists on first launch.
//

import SwiftUI
import SwiftData

@main
struct RecompCoachApp: App {

    let container: ModelContainer
    @State private var health = HealthKitManager.shared
    @State private var notifications = NotificationsManager.shared
    @State private var showSplash = true

    init() {
        let schema = Schema([
            UserProfile.self,
            DailyLog.self,
            WorkoutSession.self,
            ExerciseEntry.self,
            WeeklyCheckIn.self,
            MealLog.self,
            SupplementLog.self,
            ProgressPhoto.self
        ])
        // On-device only (no CloudKit in v1).
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                RootView()
                    .task {
                        seedProfileIfNeeded()
                        // Idempotent: re-requests only pick up scopes a later
                        // build added (e.g. dietary reads for MyFitnessPal sync)
                        // that an already-connected user hasn't granted yet.
                        if health.isConnected { await health.requestAuthorization() }
                    }
                    .environment(health)
                    .environment(notifications)

                if showSplash {
                    LaunchSplashView()
                        .transition(.opacity)
                        .zIndex(1)
                        .task {
                            try? await Task.sleep(nanoseconds: 1_400_000_000)
                            withAnimation(.easeOut(duration: 0.4)) { showSplash = false }
                        }
                }
            }
            .preferredColorScheme(.dark)
            .tint(Theme.steel)
        }
        .modelContainer(container)
    }

    /// Creates the default profile (from the handoff spec) the first time the app runs.
    private func seedProfileIfNeeded() {
        let context = container.mainContext
        let existing = try? context.fetch(FetchDescriptor<UserProfile>())
        guard (existing?.isEmpty ?? true) else { return }
        context.insert(UserProfile())
        try? context.save()
    }
}
