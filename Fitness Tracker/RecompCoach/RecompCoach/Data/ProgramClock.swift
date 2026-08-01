//
//  ProgramClock.swift
//  RecompCoach
//
//  Pure date math for translating a program start date into the current
//  week/day.
//

import Foundation

enum ProgramClock {

    private static var cal: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        return c
    }

    /// 1-based program day number for `date` given `start` (both compared at day granularity).
    static func dayNumber(start: Date, on date: Date = .now) -> Int {
        let s = cal.startOfDay(for: start)
        let d = cal.startOfDay(for: date)
        let days = cal.dateComponents([.day], from: s, to: d).day ?? 0
        return max(1, days + 1)
    }

    /// 1-based program week number.
    static func weekNumber(start: Date, on date: Date = .now) -> Int {
        max(1, Int((Double(dayNumber(start: start, on: date)) / 7.0).rounded(.up)))
    }

    /// Start-of-day date for the first day of `week` (1-based).
    static func firstDay(ofWeek week: Int, start: Date) -> Date {
        let s = cal.startOfDay(for: start)
        return cal.date(byAdding: .day, value: (week - 1) * 7, to: s) ?? s
    }

    /// The 7 calendar days (start-of-day) belonging to `week`.
    static func days(inWeek week: Int, start: Date) -> [Date] {
        let first = firstDay(ofWeek: week, start: start)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: first) }
    }
}
