//
//  NotificationsManager.swift
//  RecompCoach
//
//  Local notifications for the coaching trigger system (see
//  motivation_behavioral_system.md). There's no backend, so every trigger
//  here does one of two things: (a) schedules ahead of time, for triggers
//  whose date is knowable purely from the program start date (phase
//  transitions, deload weeks, halfway/completion, assessment weeks, workout
//  days, the evening log nudge), or (b) fires immediately at the moment the
//  app detects or creates the triggering data (missed sessions, weekly
//  summary, PRs, plateaus, streaks, a knee-pain flag).
//

import Foundation
import UserNotifications
import Observation

@Observable
final class NotificationsManager {
    static let shared = NotificationsManager()

    var isAuthorized: Bool {
        didSet { UserDefaults.standard.set(isAuthorized, forKey: "notif.authorized") }
    }

    // MARK: - Per-trigger toggles (Notifications settings screen)
    //
    // `masterEnabled` is a hard kill switch every scheduling/firing function
    // checks first; the individual flags below then gate their own specific
    // trigger. Toggling any of these doesn't retroactively cancel already-
    // pending notifications by itself — the settings screen calls
    // `rescheduleAll` after each change, which clears everything pending and
    // re-derives it from the current toggle states.

    var masterEnabled: Bool {
        didSet { UserDefaults.standard.set(masterEnabled, forKey: "notif.trigger.master") }
    }
    var workoutRemindersEnabled: Bool {
        didSet { UserDefaults.standard.set(workoutRemindersEnabled, forKey: "notif.trigger.workoutReminders") }
    }
    var eveningLogReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(eveningLogReminderEnabled, forKey: "notif.trigger.eveningLogReminder") }
    }
    var progressPhotoReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(progressPhotoReminderEnabled, forKey: "notif.trigger.progressPhotoReminder") }
    }
    var phaseTransitionsEnabled: Bool {
        didSet { UserDefaults.standard.set(phaseTransitionsEnabled, forKey: "notif.trigger.phaseTransitions") }
    }
    var deloadWeeksEnabled: Bool {
        didSet { UserDefaults.standard.set(deloadWeeksEnabled, forKey: "notif.trigger.deloadWeeks") }
    }
    var assessmentDaysEnabled: Bool {
        didSet { UserDefaults.standard.set(assessmentDaysEnabled, forKey: "notif.trigger.assessmentDays") }
    }
    var programMilestonesEnabled: Bool {
        didSet { UserDefaults.standard.set(programMilestonesEnabled, forKey: "notif.trigger.programMilestones") }
    }
    var missedSessionsEnabled: Bool {
        didSet { UserDefaults.standard.set(missedSessionsEnabled, forKey: "notif.trigger.missedSessions") }
    }
    var weeklySummaryEnabled: Bool {
        didSet { UserDefaults.standard.set(weeklySummaryEnabled, forKey: "notif.trigger.weeklySummary") }
    }
    var streaksEnabled: Bool {
        didSet { UserDefaults.standard.set(streaksEnabled, forKey: "notif.trigger.streaks") }
    }
    var kneeFlagEnabled: Bool {
        didSet { UserDefaults.standard.set(kneeFlagEnabled, forKey: "notif.trigger.kneeFlag") }
    }
    var prsEnabled: Bool {
        didSet { UserDefaults.standard.set(prsEnabled, forKey: "notif.trigger.prs") }
    }
    var plateausEnabled: Bool {
        didSet { UserDefaults.standard.set(plateausEnabled, forKey: "notif.trigger.plateaus") }
    }

    private let center = UNUserNotificationCenter.current()
    private let cal = Calendar.current
    private let delegate = BannerPresentingDelegate()

    private init() {
        isAuthorized = UserDefaults.standard.bool(forKey: "notif.authorized")
        UserDefaults.standard.register(defaults: [
            "notif.trigger.master": true, "notif.trigger.workoutReminders": true,
            "notif.trigger.eveningLogReminder": true, "notif.trigger.progressPhotoReminder": true,
            "notif.trigger.phaseTransitions": true,
            "notif.trigger.deloadWeeks": true, "notif.trigger.assessmentDays": true,
            "notif.trigger.programMilestones": true, "notif.trigger.missedSessions": true,
            "notif.trigger.weeklySummary": true, "notif.trigger.streaks": true,
            "notif.trigger.kneeFlag": true, "notif.trigger.prs": true, "notif.trigger.plateaus": true
        ])
        masterEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.master")
        workoutRemindersEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.workoutReminders")
        eveningLogReminderEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.eveningLogReminder")
        progressPhotoReminderEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.progressPhotoReminder")
        phaseTransitionsEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.phaseTransitions")
        deloadWeeksEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.deloadWeeks")
        assessmentDaysEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.assessmentDays")
        programMilestonesEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.programMilestones")
        missedSessionsEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.missedSessions")
        weeklySummaryEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.weeklySummary")
        streaksEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.streaks")
        kneeFlagEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.kneeFlag")
        prsEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.prs")
        plateausEnabled = UserDefaults.standard.bool(forKey: "notif.trigger.plateaus")
        center.delegate = delegate
    }

    /// Clears every pending local notification, then re-derives everything
    /// schedulable ahead of time from the current toggle states. Call after
    /// any Notifications-settings toggle changes.
    func rescheduleAll(startDate: Date, loggedToday: Bool) {
        center.removeAllPendingNotificationRequests()
        scheduleProgramMilestones(startDate: startDate)
        scheduleWorkoutDayReminders(startDate: startDate)
        scheduleEveningLogReminder(alreadyLoggedToday: loggedToday)
        scheduleProgressPhotoReminder(startDate: startDate)
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await MainActor.run { isAuthorized = granted }
            return granted
        } catch {
            return false
        }
    }

    // MARK: - Scheduled ahead (dates knowable purely from the program start date)

    /// Re-schedules phase-transition orientation, deload-week framing,
    /// halfway/completion milestones, and the 4-week assessment cadence.
    /// Safe to call any time (launch, or whenever `startDate` changes) —
    /// re-adding the same identifier just replaces the pending request, and
    /// past dates are skipped/cleared.
    func scheduleProgramMilestones(startDate: Date) {
        guard isAuthorized, masterEnabled else { return }

        if phaseTransitionsEnabled {
            for phase in ProgramCatalog.phases where phase.id != ProgramCatalog.phase1.id {
                schedule(
                    id: "phase-\(phase.id)",
                    title: "New phase: \(phase.name)",
                    body: phase.goals.first ?? "A new phase of the program starts today.",
                    date: morning(ProgramClock.firstDay(ofWeek: phase.weekStart, start: startDate))
                )
            }
        }

        if deloadWeeksEnabled {
            for phase in ProgramCatalog.phases {
                for week in phase.deloadWeeks {
                    schedule(
                        id: "deload-\(phase.id)-\(week)",
                        title: "Deload week",
                        body: "This week's lighter on purpose — deloads are where the last month's training actually gets absorbed, not wasted time.",
                        date: morning(ProgramClock.firstDay(ofWeek: week, start: startDate))
                    )
                }
            }
        }

        if programMilestonesEnabled {
            schedule(
                id: "milestone-halfway",
                title: "Halfway through the year",
                body: "Whatever the scale says today, you've shown up for 26 weeks — that's the actual achievement.",
                date: morning(ProgramClock.firstDay(ofWeek: 26, start: startDate))
            )
            schedule(
                id: "milestone-completion",
                title: "52 weeks complete",
                body: "One full year, logged and real. Check the History tab for the full-year assessment.",
                date: morning(ProgramClock.firstDay(ofWeek: 52, start: startDate))
            )
        }

        if assessmentDaysEnabled {
            for week in stride(from: 4, through: 48, by: 4) {
                schedule(
                    id: "assessment-week\(week)",
                    title: "Assessment day",
                    body: "Week \(week) check-in — log this week's numbers and see how the last month trended.",
                    date: morning(ProgramClock.firstDay(ofWeek: week, start: startDate))
                )
            }
        }
    }

    /// Rolling reminders for the next 14 days' scheduled workouts. The weekly
    /// split is a fixed 7-day pattern from `startDate`, so these dates are
    /// exact — no recurrence guessing needed. Call at launch/foreground.
    func scheduleWorkoutDayReminders(startDate: Date) {
        guard isAuthorized, masterEnabled, workoutRemindersEnabled else { return }
        let today = cal.startOfDay(for: .now)
        for offset in 0..<14 {
            guard let date = cal.date(byAdding: .day, value: offset, to: today) else { continue }
            let programDay = ProgramClock.dayNumber(start: startDate, on: date)
            guard let type = ProgramCatalog.scheduledWorkout(forProgramDay: programDay).workout else { continue }
            schedule(
                id: "workoutday-\(dayKey(date))",
                title: "Today: \(type.displayName)",
                body: "Same plan as always: warm up, work the lifts, don't chase a number that isn't there today.",
                date: morning(date, hour: 7)
            )
        }
    }

    /// Tonight's "log your day" nudge — cancelled if today's already logged.
    func scheduleEveningLogReminder(alreadyLoggedToday: Bool) {
        let id = "eveninglog-\(dayKey(.now))"
        guard isAuthorized, masterEnabled, eveningLogReminderEnabled, !alreadyLoggedToday else {
            center.removePendingNotificationRequests(withIdentifiers: [id])
            return
        }
        schedule(
            id: id,
            title: "Log today",
            body: "Weight, sleep, knee pain — takes under a minute.",
            date: morning(.now, hour: 20, minute: 30)
        )
    }

    /// Monthly nudge to capture a progress photo, anchored to the day-of-month
    /// the program started. Unlike the other scheduled-ahead reminders, this
    /// is a single repeating request (day+hour+minute only, no month/year) —
    /// there's no fixed end date to enumerate, so iOS re-fires it every month
    /// on its own rather than us re-deriving 12+ individual dates.
    func scheduleProgressPhotoReminder(startDate: Date) {
        let id = "progressphoto-monthly"
        guard isAuthorized, masterEnabled, progressPhotoReminderEnabled else {
            center.removePendingNotificationRequests(withIdentifiers: [id])
            return
        }
        var comps = cal.dateComponents([.day], from: startDate)
        comps.hour = 9
        comps.minute = 0
        let content = UNMutableNotificationContent()
        content.title = "Monthly progress photo"
        content.body = "Same spot, same lighting if you can — takes 30 seconds, and the trend only means something with every month in it."
        content.sound = .default
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    // MARK: - Foreground-detected (need real logged data to evaluate)

    /// "2+ consecutive scheduled sessions missed" — checks scheduled days
    /// before today against logged sessions. Fires at most once per day.
    func checkMissedSessions(startDate: Date, sessions: [WorkoutSession]) {
        guard isAuthorized, masterEnabled, missedSessionsEnabled else { return }
        let today = cal.startOfDay(for: .now)
        let loggedDays = Set(sessions.map { cal.startOfDay(for: $0.date) })

        var missed = 0
        var cursor = today
        while missed < 2 {
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
            let programDay = ProgramClock.dayNumber(start: startDate, on: prev)
            guard ProgramCatalog.scheduledWorkout(forProgramDay: programDay).workout != nil else { continue }
            if loggedDays.contains(prev) { break }
            missed += 1
        }
        guard missed >= 2 else { return }

        let key = "notif.missedSessions.lastFiredDay"
        let todayKey = dayKey(today)
        guard UserDefaults.standard.string(forKey: key) != todayKey else { return }
        UserDefaults.standard.set(todayKey, forKey: key)

        fireNow(
            id: "missed-\(todayKey)",
            title: "A couple sessions slipped",
            body: "One missed session doesn't undo the last few weeks. Next one's what matters — when's it happening?"
        )
    }

    /// Weekly summary — fires once, the first time the app opens after a
    /// program week ends, summarizing that week from logged data.
    func checkWeeklySummary(startDate: Date, dailyLogs: [DailyLog], sessions: [WorkoutSession]) {
        guard isAuthorized, masterEnabled, weeklySummaryEnabled else { return }
        let currentWeek = ProgramClock.weekNumber(start: startDate)
        let priorWeek = currentWeek - 1
        guard priorWeek >= 1 else { return }

        let key = "notif.weeklySummary.lastFiredWeek"
        guard UserDefaults.standard.integer(forKey: key) < priorWeek else { return }

        let days = ProgramClock.days(inWeek: priorWeek, start: startDate)
        guard let weekStart = days.first, let weekEnd = days.last else { return }
        let inRange: (Date) -> Bool = { [cal] d in
            let day = cal.startOfDay(for: d)
            return day >= weekStart && day <= weekEnd
        }

        let weekLogs = dailyLogs.filter { inRange($0.date) }
        let weekSessions = sessions.filter { inRange($0.date) }
        let sleeps = weekLogs.compactMap(\.sleepHours)
        let weights = weekLogs.compactMap(\.weightLb).sorted()
        let kneeScores = weekLogs.compactMap(\.kneePainScore)

        var parts: [String] = ["\(weekSessions.count) of 4 sessions completed"]
        if !sleeps.isEmpty {
            parts.append("avg sleep \(String(format: "%.1f", sleeps.reduce(0, +) / Double(sleeps.count)))h")
        }
        if weights.count >= 2, let first = weights.first, let last = weights.last {
            let delta = last - first
            let arrow = delta > 0 ? "\u{2191}" : delta < 0 ? "\u{2193}" : "\u{2192}"
            parts.append("weight \(arrow) \(String(format: "%.1f", abs(delta))) lb")
        }
        if kneeScores.count >= 2, let first = kneeScores.first, let last = kneeScores.last {
            let trend = last > first ? "worse" : last < first ? "better" : "steady"
            parts.append("knee trending \(trend)")
        }

        UserDefaults.standard.set(priorWeek, forKey: key)
        fireNow(
            id: "weekly-summary-\(priorWeek)",
            title: "Week \(priorWeek) summary",
            body: "This week: " + parts.joined(separator: " \u{b7} ") + "."
        )
    }

    /// "7-day daily-log streak reached" — fires once per new multiple of 7.
    func checkStreak(dailyLogs: [DailyLog]) {
        guard isAuthorized, masterEnabled, streaksEnabled else { return }
        let loggedDays = Set(dailyLogs.map { cal.startOfDay(for: $0.date) })
        var streak = 0
        var day = cal.startOfDay(for: .now)
        while loggedDays.contains(day) {
            streak += 1
            guard let prev = cal.date(byAdding: .day, value: -1, to: day) else { break }
            day = prev
        }
        guard streak > 0, streak % 7 == 0 else { return }

        let key = "notif.streak.lastAnnouncedCount"
        guard UserDefaults.standard.integer(forKey: key) < streak else { return }
        UserDefaults.standard.set(streak, forKey: key)

        fireNow(
            id: "streak-\(streak)",
            title: "\(streak)-day logging streak",
            body: "That's the habit becoming automatic."
        )
    }

    /// "Knee pain score \u{2265}5 logged" — a calm, direct flag, not a celebration.
    /// Guarded per day+score so repeated saves of the same value don't re-fire.
    func checkKneePainFlag(day: Date, score: Int?) {
        guard isAuthorized, masterEnabled, kneeFlagEnabled, let score, score >= 5 else { return }
        let key = "notif.kneeflag.\(dayKey(day))"
        guard UserDefaults.standard.integer(forKey: key) != score else { return }
        UserDefaults.standard.set(score, forKey: key)
        fireNow(
            id: "kneeflag-\(dayKey(day))",
            title: "Knee pain flagged",
            body: "Logged at \(score)/10 — back off today and check the gate-check guidance before your next lower-body session."
        )
    }

    // MARK: - Immediate (fired right when a workout save creates the event)

    func announcePR(exerciseName: String, weightLb: Double, reps: Int) {
        guard isAuthorized, masterEnabled, prsEnabled else { return }
        fireNow(
            id: "pr-\(UUID().uuidString)",
            title: "New PR",
            body: "\(exerciseName) at \(trimmed(weightLb)) lb \u{d7} \(reps). That's real progress, logged and real."
        )
    }

    func announcePlateau(exerciseName: String) {
        guard isAuthorized, masterEnabled, plateausEnabled else { return }
        fireNow(
            id: "plateau-\(UUID().uuidString)",
            title: "\(exerciseName) has been flat",
            body: "Three sessions with no change — normal, not a sign anything's wrong. Check sleep, whether the last deload actually happened, and whether reps/form have been fully clean."
        )
    }

    // MARK: - Helpers

    private func morning(_ date: Date, hour: Int = 8, minute: Int = 0) -> Date {
        cal.date(bySettingHour: hour, minute: minute, second: 0, of: date) ?? date
    }

    private func schedule(id: String, title: String, body: String, date: Date) {
        guard date > .now else {
            center.removePendingNotificationRequests(withIdentifiers: [id])
            return
        }
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func fireNow(id: String, title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }

    private func dayKey(_ date: Date) -> String {
        let comps = cal.dateComponents([.year, .month, .day], from: date)
        return "\(comps.year ?? 0)-\(comps.month ?? 0)-\(comps.day ?? 0)"
    }

    private func trimmed(_ v: Double) -> String {
        v.truncatingRemainder(dividingBy: 1) == 0 ? String(Int(v)) : String(format: "%.1f", v)
    }
}

/// Lets local notifications show as a banner even while the app is in the
/// foreground (e.g. a PR notification fired right after finishing a workout).
private final class BannerPresentingDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }
}
