//
//  RootView.swift
//  RecompCoach
//
//  App shell (ref-app-2 look): a warm glow canvas, a slim transparent header
//  ("Today" + calendar dropdown, and a profile avatar), the selected tab's
//  content, and a floating pill tab bar with the active item in a filled square.
//

import SwiftUI
import SwiftData
import UIKit

enum AppTab: Int, CaseIterable {
    case home, workout, food, history

    var title: String {
        switch self {
        case .home: return "Home"
        case .workout: return "Workout"
        case .food: return "Food"
        case .history: return "History"
        }
    }
    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .workout: return "dumbbell.fill"
        case .food: return "fork.knife"
        case .history: return "chart.xyaxis.line"
        }
    }
}

/// App-wide navigation router. Lets one tab drive another — e.g. Home's
/// "Begin Workout" switches to the Workout tab and starts that session.
@Observable final class AppRouter {
    var tab: AppTab = .home
    /// Set by Home to ask the Workout tab to open this session.
    var pendingWorkout: WorkoutType?
    /// When starting via "Begin Workout", jump straight into the first exercise;
    /// when opening via the card body, land on the exercise list.
    var pendingOpenFirstExercise = false
    /// The in-progress workout, held here (not in WorkoutView's @State) so it
    /// survives leaving and returning to the Workout tab. Nil until one starts.
    var draft: WorkoutDraft?
    /// Navigation path for the Workout tab's stack, hoisted for the same reason.
    var workoutPath: [WorkoutRoute] = []
    /// Navigation paths for the Home and Food tabs' stacks, hoisted (like
    /// `workoutPath`) so re-tapping an already-active tab can pop it to root.
    var homePath: [HomeRoute] = []
    var foodPath: [HomeRoute] = []
    /// The day Home is showing — shared with the header's "Today" calendar
    /// dropdown so both pickers stay in sync.
    var selectedDate: Date = Calendar.current.startOfDay(for: .now)
}

struct RootView: View {
    @Query private var profiles: [UserProfile]
    @Query private var dailyLogs: [DailyLog]
    @Query private var sessions: [WorkoutSession]

    @Environment(NotificationsManager.self) private var notifications
    @Environment(\.scenePhase) private var scenePhase

    @State private var router = AppRouter()
    @State private var showCalendar = false
    @State private var showProfile = false

    private var profile: UserProfile? { profiles.first }
    private var cal: Calendar { Calendar.current }

    // Only the profile sheet blurs the background — the calendar's own glass
    // material already reads clearly over the sharp app content behind it.
    private var isPresentingOverlay: Bool { showProfile }

    var body: some View {
        @Bindable var router = router
        return ZStack {
            GlowBackground()
                .blurredWhenPresenting(isPresentingOverlay)
            VStack(spacing: 0) {
                // The header stays sharp — only what's behind/below it recedes.
                header
                content
                    .blurredWhenPresenting(isPresentingOverlay)
            }
        }
        .environment(router)
        .safeAreaInset(edge: .bottom) {
            FloatingTabBar(router: router)
                .blurredWhenPresenting(isPresentingOverlay)
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
        .task { refreshNotifications() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active { refreshNotifications() }
        }
    }

    /// Re-schedules/checks every notification trigger. Cheap and idempotent —
    /// safe to call on launch and every time the app returns to the foreground.
    private func refreshNotifications() {
        guard notifications.isAuthorized, let p = profile else { return }
        notifications.scheduleProgramMilestones(startDate: p.startDate)
        notifications.scheduleWorkoutDayReminders(startDate: p.startDate)
        let loggedToday = dailyLogs.contains { cal.isDateInToday($0.date) }
        notifications.scheduleEveningLogReminder(alreadyLoggedToday: loggedToday)
        notifications.scheduleProgressPhotoReminder(startDate: p.startDate)
        notifications.checkMissedSessions(startDate: p.startDate, sessions: sessions)
        notifications.checkWeeklySummary(startDate: p.startDate, dailyLogs: dailyLogs, sessions: sessions)
    }

    @ViewBuilder private var content: some View {
        switch router.tab {
        case .home: HomeView()
        case .workout: WorkoutView()
        case .food: FoodView()
        case .history: HistoryView()
        }
    }

    // MARK: Header

    private var todayLabel: String {
        cal.isDateInToday(router.selectedDate) ? "Today" : router.selectedDate.formatted(.dateTime.month(.abbreviated).day())
    }

    private var header: some View {
        // ZStack so "Today" sits dead-center regardless of how wide the
        // logomark/profile sides are, rather than approximating it with
        // flexible-width HStack sections.
        ZStack {
            todayButton
            HStack(alignment: .center) {
                logomark
                Spacer()
                profileButton
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 6)
        .padding(.bottom, 12)
    }

    private var logomark: some View {
        Image("Logomark")
            .resizable()
            .scaledToFit()
            .frame(height: 26)
    }

    private var todayButton: some View {
        @Bindable var router = router
        return Button { showCalendar = true } label: {
            HStack(spacing: 5) {
                Text(todayLabel)
                    .font(Theme.display(24, weight: .bold))
                    .foregroundStyle(Theme.chalk)
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .buttonStyle(.plain)
        .popover(isPresented: $showCalendar, attachmentAnchor: .point(.bottom), arrowEdge: .top) {
            CalendarPickerSheet(selection: $router.selectedDate)
                .presentationCompactAdaptation(.popover)
        }
    }

    private var profileButton: some View {
        Button { showProfile = true } label: {
            HStack(spacing: 8) {
                if !(profile?.name.isEmpty ?? true) {
                    Text(profile!.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Theme.chalkDim)
                }
                AvatarView(photoData: profile?.photoData, diameter: 34)
            }
        }
        .buttonStyle(.plain)
    }
}

/// Small circular profile photo, falling back to a person glyph when unset.
struct AvatarView: View {
    let photoData: Data?
    var diameter: CGFloat = 34

    var body: some View {
        Group {
            if let photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    Theme.iron2
                    Image(systemName: "person.fill")
                        .font(.system(size: diameter * 0.45))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
        }
        .frame(width: diameter, height: diameter)
        .clipShape(Circle())
        .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
    }
}

// MARK: - Floating pill tab bar

struct FloatingTabBar: View {
    var router: AppRouter

    var body: some View {
        HStack(spacing: 4) {
            ForEach(AppTab.allCases, id: \.self) { tab in
                item(tab)
            }
        }
        .padding(6)
        .background(
            // Radius = the active tab's 14pt radius + this 6pt padding, so
            // the pill and the highlighted square read as concentric.
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 20).fill(Theme.iron.opacity(0.55)))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Theme.hairline, lineWidth: 1))
                .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
        )
        .padding(.horizontal, 40)
        // Extra top padding widens the reserved inset so scrolled content
        // clears the floating bar (and its shadow) with breathing room.
        .padding(.top, 22)
        .padding(.bottom, 6)
        .background(
            // Full-width plate behind the pill, matching the reserved inset's
            // height exactly, so scrolled content reads as clearly separated
            // from the tab-bar zone the same way it's separated from the
            // header. The pill itself doesn't span the screen, so the plate
            // is force-bled edge to edge with oversized horizontal padding
            // rather than relying on a frame proposal it won't get here.
            // The solid stop holds until 20% up so there's a flat black base
            // before the fade begins, rather than fading from the very edge.
            LinearGradient(
                stops: [
                    .init(color: .black.opacity(0.85), location: 0.0),
                    .init(color: .black.opacity(0.85), location: 0.2),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .bottom, endPoint: .top
            )
                .padding(.horizontal, -1000)
                .ignoresSafeArea(edges: .bottom)
        )
    }

    private func item(_ tab: AppTab) -> some View {
        let isActive = tab == router.tab
        return Button {
            withAnimation(.easeInOut(duration: 0.18)) {
                if router.tab == tab {
                    // Re-tapping the already-active tab pops its stack to root,
                    // so a pushed detail view is always one tap from home.
                    switch tab {
                    case .home: router.homePath = []
                    case .food: router.foodPath = []
                    case .workout: router.workoutPath = []
                    case .history: break
                    }
                } else {
                    router.tab = tab
                }
            }
        } label: {
            Image(systemName: tab.icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isActive ? Color(hex: 0x151515) : Theme.chalkDim)
                .frame(width: 46, height: 46)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(isActive ? Color.white : Color.clear)
                )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }
}
