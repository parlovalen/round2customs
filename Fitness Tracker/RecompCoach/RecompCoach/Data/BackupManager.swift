//
//  BackupManager.swift
//  RecompCoach
//
//  Manual JSON backup / restore for all user-generated data. Since v1 is
//  on-device only (no iCloud sync), this is the safety net: export everything to
//  a file the user controls, and restore it later (e.g. after deleting the app
//  or on a new phone). Program content (workouts/meals) is authored in code and
//  is NOT part of the backup — only logged data is.
//

import Foundation
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Codable snapshot

/// Top-level backup payload. `version` lets future restores stay compatible.
struct BackupFile: Codable {
    var version: Int = 1
    var exportedAt: Date
    var profile: ProfileDTO?
    var dailyLogs: [DailyLogDTO]
    var sessions: [SessionDTO]
    var mealLogs: [MealLogDTO]
    var checkIns: [CheckInDTO]
    /// Optional so backups written before supplement tracking still decode.
    var supplementLogs: [SupplementLogDTO]?
    /// Optional so backups written before progress photos existed still decode.
    var progressPhotos: [ProgressPhotoDTO]?
}

struct ProfileDTO: Codable {
    /// Optional so backups written before the profile name/photo existed still decode.
    var name: String?
    var photoData: Data?
    var age: Int
    var heightCm: Double
    var startWeightLb: Double
    var biologicalSex: String
    var bodyFatEstimatePercent: Double
    var goal: String
    var trainingDaysPerWeek: Int
    var startDate: Date
    var dailyCalorieTarget: Int
    var proteinTargetG: Int
    var carbTargetG: Int
    var fatTargetG: Int
    var waterTargetL: Double
    var healthKitSyncEnabled: Bool
    /// Optional so backups written before Phase 5 specialization tracking still decode.
    var specializationTrackRaw: String?
}

struct DailyLogDTO: Codable {
    var date: Date
    var weightLb: Double?
    var calories: Int?
    var proteinG: Int?
    var carbG: Int?
    var fatG: Int?
    var waterL: Double?
    var sleepHours: Double?
    var steps: Int?
    var moodScore: Int?
    var sorenessScore: Int?
    var kneePainScore: Int?
    var notes: String
}

struct EntryDTO: Codable {
    var exerciseId: String
    var exerciseName: String
    var weightLb: Double?
    var repsText: String
    var rpe: Double?
    var holdSeconds: Int?
    /// Optional so backups written before per-set logging still decode.
    var sets: [LoggedSet]?
}

struct SessionDTO: Codable {
    var date: Date
    var workoutTypeRaw: String
    var kneePainDuring: Int?
    var kneePainNextMorning: Int?
    var notes: String
    var entries: [EntryDTO]
}

struct MealLogDTO: Codable {
    var date: Date
    var mealTypeRaw: String
    var mealId: String
    var name: String
    var kcal: Int
    var proteinG: Int
    var carbG: Int
    var fatG: Int
    var loggedAt: Date
}

struct SupplementLogDTO: Codable {
    var date: Date
    var supplementId: String
    var takenAt: Date
}

struct ProgressPhotoDTO: Codable {
    var date: Date
    var photoData: Data
    var notes: String
}

struct CheckInDTO: Codable {
    var weekNumber: Int
    var weightChangeLb: Double?
    var avgSleepHours: Double?
    var sessionsCompleted: Int?
    var kneeTrendRaw: String
    var feltHard: String
    var feltGood: String
    var createdAt: Date
}

/// Counts returned after a restore, for a confirmation message.
struct RestoreSummary {
    var dailyLogs = 0
    var sessions = 0
    var mealLogs = 0
    var checkIns = 0
    var supplementLogs = 0
    var progressPhotos = 0
    var total: Int { dailyLogs + sessions + mealLogs + checkIns + supplementLogs + progressPhotos }
}

// MARK: - Manager

enum BackupManager {

    private static var encoder: JSONEncoder {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        e.outputFormatting = [.prettyPrinted, .sortedKeys]
        return e
    }

    private static var decoder: JSONDecoder {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }

    /// Suggested filename, e.g. "RecompCoach-backup-2026-07-20.json".
    static func defaultFilename() -> String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return "RecompCoach-backup-\(fmt.string(from: .now))"
    }

    /// Serialize every logged record to JSON.
    static func exportData(context: ModelContext) throws -> Data {
        let profile = try context.fetch(FetchDescriptor<UserProfile>()).first
        let logs = try context.fetch(FetchDescriptor<DailyLog>())
        let sessions = try context.fetch(FetchDescriptor<WorkoutSession>())
        let meals = try context.fetch(FetchDescriptor<MealLog>())
        let checkIns = try context.fetch(FetchDescriptor<WeeklyCheckIn>())
        let supplements = try context.fetch(FetchDescriptor<SupplementLog>())
        let progressPhotos = try context.fetch(FetchDescriptor<ProgressPhoto>())

        let file = BackupFile(
            exportedAt: .now,
            profile: profile.map {
                ProfileDTO(
                    name: $0.name, photoData: $0.photoData,
                    age: $0.age, heightCm: $0.heightCm, startWeightLb: $0.startWeightLb,
                    biologicalSex: $0.biologicalSex, bodyFatEstimatePercent: $0.bodyFatEstimatePercent,
                    goal: $0.goal, trainingDaysPerWeek: $0.trainingDaysPerWeek, startDate: $0.startDate,
                    dailyCalorieTarget: $0.dailyCalorieTarget, proteinTargetG: $0.proteinTargetG,
                    carbTargetG: $0.carbTargetG, fatTargetG: $0.fatTargetG, waterTargetL: $0.waterTargetL,
                    healthKitSyncEnabled: $0.healthKitSyncEnabled,
                    specializationTrackRaw: $0.specializationTrackRaw
                )
            },
            dailyLogs: logs.map {
                DailyLogDTO(
                    date: $0.date, weightLb: $0.weightLb, calories: $0.calories, proteinG: $0.proteinG,
                    carbG: $0.carbG, fatG: $0.fatG, waterL: $0.waterL, sleepHours: $0.sleepHours,
                    steps: $0.steps, moodScore: $0.moodScore, sorenessScore: $0.sorenessScore,
                    kneePainScore: $0.kneePainScore, notes: $0.notes
                )
            },
            sessions: sessions.map { s in
                SessionDTO(
                    date: s.date, workoutTypeRaw: s.workoutTypeRaw, kneePainDuring: s.kneePainDuring,
                    kneePainNextMorning: s.kneePainNextMorning, notes: s.notes,
                    entries: s.entries.map {
                        EntryDTO(
                            exerciseId: $0.exerciseId, exerciseName: $0.exerciseName,
                            weightLb: $0.weightLb, repsText: $0.repsText, rpe: $0.rpe,
                            holdSeconds: $0.holdSeconds, sets: $0.sets
                        )
                    }
                )
            },
            mealLogs: meals.map {
                MealLogDTO(
                    date: $0.date, mealTypeRaw: $0.mealTypeRaw, mealId: $0.mealId, name: $0.name,
                    kcal: $0.kcal, proteinG: $0.proteinG, carbG: $0.carbG, fatG: $0.fatG,
                    loggedAt: $0.loggedAt
                )
            },
            checkIns: checkIns.map {
                CheckInDTO(
                    weekNumber: $0.weekNumber, weightChangeLb: $0.weightChangeLb,
                    avgSleepHours: $0.avgSleepHours, sessionsCompleted: $0.sessionsCompleted,
                    kneeTrendRaw: $0.kneeTrendRaw, feltHard: $0.feltHard, feltGood: $0.feltGood,
                    createdAt: $0.createdAt
                )
            },
            supplementLogs: supplements.map {
                SupplementLogDTO(date: $0.date, supplementId: $0.supplementId, takenAt: $0.takenAt)
            },
            progressPhotos: progressPhotos.map {
                ProgressPhotoDTO(date: $0.date, photoData: $0.photoData, notes: $0.notes)
            }
        )
        return try encoder.encode(file)
    }

    /// Replace all logged data with the contents of a backup file. Existing rows
    /// are deleted first so unique keys (day / week) don't collide.
    @discardableResult
    static func restore(from data: Data, context: ModelContext) throws -> RestoreSummary {
        let file = try decoder.decode(BackupFile.self, from: data)

        // Wipe current logged data.
        for x in try context.fetch(FetchDescriptor<DailyLog>()) { context.delete(x) }
        for x in try context.fetch(FetchDescriptor<WorkoutSession>()) { context.delete(x) } // cascades entries
        for x in try context.fetch(FetchDescriptor<MealLog>()) { context.delete(x) }
        for x in try context.fetch(FetchDescriptor<WeeklyCheckIn>()) { context.delete(x) }
        for x in try context.fetch(FetchDescriptor<SupplementLog>()) { context.delete(x) }
        for x in try context.fetch(FetchDescriptor<ProgressPhoto>()) { context.delete(x) }

        var summary = RestoreSummary()

        // Profile: only replace if the backup carried one.
        if let p = file.profile {
            for x in try context.fetch(FetchDescriptor<UserProfile>()) { context.delete(x) }
            let profile = UserProfile(
                name: p.name ?? "", photoData: p.photoData,
                age: p.age, heightCm: p.heightCm, startWeightLb: p.startWeightLb,
                biologicalSex: p.biologicalSex, bodyFatEstimatePercent: p.bodyFatEstimatePercent,
                goal: p.goal, trainingDaysPerWeek: p.trainingDaysPerWeek, startDate: p.startDate,
                dailyCalorieTarget: p.dailyCalorieTarget, proteinTargetG: p.proteinTargetG,
                carbTargetG: p.carbTargetG, fatTargetG: p.fatTargetG, waterTargetL: p.waterTargetL,
                healthKitSyncEnabled: p.healthKitSyncEnabled,
                specializationTrackRaw: p.specializationTrackRaw
            )
            context.insert(profile)
        }

        for d in file.dailyLogs {
            let log = DailyLog(
                date: d.date, weightLb: d.weightLb, calories: d.calories, proteinG: d.proteinG,
                carbG: d.carbG, fatG: d.fatG, waterL: d.waterL, sleepHours: d.sleepHours,
                steps: d.steps, moodScore: d.moodScore, sorenessScore: d.sorenessScore,
                kneePainScore: d.kneePainScore, notes: d.notes
            )
            context.insert(log)
            summary.dailyLogs += 1
        }

        for s in file.sessions {
            guard let type = WorkoutType(rawValue: s.workoutTypeRaw) else { continue }
            let session = WorkoutSession(
                date: s.date, workoutType: type, kneePainDuring: s.kneePainDuring,
                kneePainNextMorning: s.kneePainNextMorning, notes: s.notes
            )
            context.insert(session)
            for e in s.entries {
                let entry = ExerciseEntry(
                    exerciseId: e.exerciseId, exerciseName: e.exerciseName, weightLb: e.weightLb,
                    repsText: e.repsText, rpe: e.rpe, holdSeconds: e.holdSeconds, sets: e.sets ?? []
                )
                session.entries.append(entry)
            }
            summary.sessions += 1
        }

        for m in file.mealLogs {
            let meal = MealLog(
                date: m.date, mealTypeRaw: m.mealTypeRaw, mealId: m.mealId, name: m.name,
                kcal: m.kcal, proteinG: m.proteinG, carbG: m.carbG, fatG: m.fatG, loggedAt: m.loggedAt
            )
            context.insert(meal)
            summary.mealLogs += 1
        }

        for sup in file.supplementLogs ?? [] {
            context.insert(SupplementLog(date: sup.date, supplementId: sup.supplementId, takenAt: sup.takenAt))
            summary.supplementLogs += 1
        }

        for photo in file.progressPhotos ?? [] {
            context.insert(ProgressPhoto(date: photo.date, photoData: photo.photoData, notes: photo.notes))
            summary.progressPhotos += 1
        }

        for c in file.checkIns {
            let checkIn = WeeklyCheckIn(
                weekNumber: c.weekNumber, weightChangeLb: c.weightChangeLb,
                avgSleepHours: c.avgSleepHours, sessionsCompleted: c.sessionsCompleted,
                kneeTrend: KneeTrend(rawValue: c.kneeTrendRaw) ?? .same,
                feltHard: c.feltHard, feltGood: c.feltGood, createdAt: c.createdAt
            )
            context.insert(checkIn)
            summary.checkIns += 1
        }

        try context.save()
        return summary
    }
}

// MARK: - File document

/// Wraps the backup JSON so SwiftUI's `.fileExporter` can write it to Files.
struct JSONBackupDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data
    init(data: Data) { self.data = data }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
