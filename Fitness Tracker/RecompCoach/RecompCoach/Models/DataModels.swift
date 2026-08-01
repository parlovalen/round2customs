//
//  DataModels.swift
//  RecompCoach
//
//  SwiftData models for user-generated, persisted data. On-device only
//  (no CloudKit in v1). Mirrors trackingSchema + userProfile/nutritionTargets
//  from app_data_model_example.json.
//

import Foundation
import SwiftData

// MARK: - Profile & targets

/// Single-instance profile row. Holds identity, program start date, and the
/// current nutrition targets (denormalized here since v1 has one active target set).
@Model
final class UserProfile {
    // Identity / physical
    /// Display name, shown next to the avatar in the app header.
    var name: String = ""
    /// Profile photo, downscaled JPEG. Additive/optional so existing profiles
    /// decode without a photo until the user sets one.
    @Attribute(.externalStorage) var photoData: Data?
    var age: Int
    var heightCm: Double
    var startWeightLb: Double
    var biologicalSex: String
    var bodyFatEstimatePercent: Double
    var goal: String
    var trainingDaysPerWeek: Int

    /// Day 1 of the 52-week program. Drives current week/day math everywhere.
    var startDate: Date

    // Nutrition targets
    var dailyCalorieTarget: Int
    var proteinTargetG: Int
    var carbTargetG: Int
    var fatTargetG: Int
    var waterTargetL: Double

    // Health integration toggle (wired to HealthKit later)
    var healthKitSyncEnabled: Bool

    /// Phase 5+ choose-your-focus track (see `SpecializationTrack`). Additive,
    /// nil until the user picks one on the History tab's Program card.
    var specializationTrackRaw: String?

    init(
        name: String = "",
        photoData: Data? = nil,
        age: Int = 42,
        heightCm: Double = 180.3,
        startWeightLb: Double = 187,
        biologicalSex: String = "male",
        bodyFatEstimatePercent: Double = 22,
        goal: String = "recomposition",
        trainingDaysPerWeek: Int = 4,
        startDate: Date = .now,
        dailyCalorieTarget: Int = 2600,
        proteinTargetG: Int = 185,
        carbTargetG: Int = 285,
        fatTargetG: Int = 80,
        waterTargetL: Double = 3.75,
        healthKitSyncEnabled: Bool = false,
        specializationTrackRaw: String? = nil
    ) {
        self.name = name
        self.photoData = photoData
        self.age = age
        self.heightCm = heightCm
        self.startWeightLb = startWeightLb
        self.biologicalSex = biologicalSex
        self.bodyFatEstimatePercent = bodyFatEstimatePercent
        self.goal = goal
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.startDate = startDate
        self.dailyCalorieTarget = dailyCalorieTarget
        self.proteinTargetG = proteinTargetG
        self.carbTargetG = carbTargetG
        self.fatTargetG = fatTargetG
        self.waterTargetL = waterTargetL
        self.healthKitSyncEnabled = healthKitSyncEnabled
        self.specializationTrackRaw = specializationTrackRaw
    }

    var specializationTrack: SpecializationTrack? {
        get { specializationTrackRaw.flatMap(SpecializationTrack.init) }
        set { specializationTrackRaw = newValue?.rawValue }
    }
}

// MARK: - Daily log

/// One entry per calendar day: bodyweight, nutrition, sleep, recovery signals.
@Model
final class DailyLog {
    /// Normalized to start-of-day; unique key for a day's entry.
    @Attribute(.unique) var date: Date

    var weightLb: Double?
    var calories: Int?
    var proteinG: Int?
    var carbG: Int?
    var fatG: Int?
    var waterL: Double?
    var sleepHours: Double?
    var steps: Int?
    var moodScore: Int?        // 1–5
    var sorenessScore: Int?    // 1–5
    var kneePainScore: Int?    // 0–10
    var notes: String

    init(
        date: Date,
        weightLb: Double? = nil,
        calories: Int? = nil,
        proteinG: Int? = nil,
        carbG: Int? = nil,
        fatG: Int? = nil,
        waterL: Double? = nil,
        sleepHours: Double? = nil,
        steps: Int? = nil,
        moodScore: Int? = nil,
        sorenessScore: Int? = nil,
        kneePainScore: Int? = nil,
        notes: String = ""
    ) {
        self.date = date
        self.weightLb = weightLb
        self.calories = calories
        self.proteinG = proteinG
        self.carbG = carbG
        self.fatG = fatG
        self.waterL = waterL
        self.sleepHours = sleepHours
        self.steps = steps
        self.moodScore = moodScore
        self.sorenessScore = sorenessScore
        self.kneePainScore = kneePainScore
        self.notes = notes
    }
}

// MARK: - Workout session

/// A logged training session. `workoutTypeRaw` stores a `WorkoutType.rawValue`.
@Model
final class WorkoutSession {
    var date: Date
    var workoutTypeRaw: String
    var kneePainDuring: Int?     // 0–10, during session
    var kneePainNextMorning: Int? // 0–10, logged the day after
    var notes: String

    @Relationship(deleteRule: .cascade, inverse: \ExerciseEntry.session)
    var entries: [ExerciseEntry]

    init(
        date: Date,
        workoutType: WorkoutType,
        kneePainDuring: Int? = nil,
        kneePainNextMorning: Int? = nil,
        notes: String = "",
        entries: [ExerciseEntry] = []
    ) {
        self.date = date
        self.workoutTypeRaw = workoutType.rawValue
        self.kneePainDuring = kneePainDuring
        self.kneePainNextMorning = kneePainNextMorning
        self.notes = notes
        self.entries = entries
    }

    var workoutType: WorkoutType? { WorkoutType(rawValue: workoutTypeRaw) }
}

/// One logged set: weight + reps (or a timed hold for isometrics).
struct LoggedSet: Codable, Hashable {
    var weightLb: Double?
    var reps: Int?
    var holdSeconds: Int?
}

/// One exercise's logged result within a session. `sets` holds the per-set
/// detail from the guided logger; `weightLb`/`repsText` are kept as a rolled-up
/// summary so History and HealthKit stay simple.
@Model
final class ExerciseEntry {
    var exerciseId: String
    var exerciseName: String
    var weightLb: Double?
    /// Reps entered free-form, e.g. "8,8,7" — preserved as typed.
    var repsText: String
    var rpe: Double?
    var holdSeconds: Int?   // for isometric holds
    /// Per-set breakdown (added with the guided logger). Additive, defaults empty.
    var sets: [LoggedSet] = []

    var session: WorkoutSession?

    init(
        exerciseId: String,
        exerciseName: String,
        weightLb: Double? = nil,
        repsText: String = "",
        rpe: Double? = nil,
        holdSeconds: Int? = nil,
        sets: [LoggedSet] = []
    ) {
        self.exerciseId = exerciseId
        self.exerciseName = exerciseName
        self.weightLb = weightLb
        self.repsText = repsText
        self.rpe = rpe
        self.holdSeconds = holdSeconds
        self.sets = sets
    }
}

// MARK: - Meal log

/// A meal the user marked as eaten. Lets the dashboard show what's been logged
/// and roll nutrition up per day.
@Model
final class MealLog {
    var date: Date          // start-of-day
    var mealTypeRaw: String // MealType.rawValue
    var mealId: String      // MealDef.id
    var name: String
    var kcal: Int
    var proteinG: Int
    var carbG: Int
    var fatG: Int
    var loggedAt: Date

    init(
        date: Date,
        mealType: MealType,
        meal: MealDef,
        loggedAt: Date = .now
    ) {
        self.date = date
        self.mealTypeRaw = mealType.rawValue
        self.mealId = meal.id
        self.name = meal.name
        self.kcal = meal.kcal
        self.proteinG = meal.proteinG
        self.carbG = meal.carbG
        self.fatG = meal.fatG
        self.loggedAt = loggedAt
    }

    /// Raw initializer used when restoring from a backup file (no `MealDef` on hand).
    init(
        date: Date,
        mealTypeRaw: String,
        mealId: String,
        name: String,
        kcal: Int,
        proteinG: Int,
        carbG: Int,
        fatG: Int,
        loggedAt: Date
    ) {
        self.date = date
        self.mealTypeRaw = mealTypeRaw
        self.mealId = mealId
        self.name = name
        self.kcal = kcal
        self.proteinG = proteinG
        self.carbG = carbG
        self.fatG = fatG
        self.loggedAt = loggedAt
    }

    var mealType: MealType? { MealType(rawValue: mealTypeRaw) }
}

// MARK: - Supplement log

/// One record that a recommended supplement was taken on a given day. Presence
/// of a row = "taken"; toggling off deletes it. `supplementId` maps to a
/// `SupplementDef` in the authored `SupplementCatalog`.
@Model
final class SupplementLog {
    var date: Date          // start-of-day
    var supplementId: String
    var takenAt: Date

    init(date: Date, supplementId: String, takenAt: Date = .now) {
        self.date = date
        self.supplementId = supplementId
        self.takenAt = takenAt
    }
}

// MARK: - Weekly check-in

enum KneeTrend: String, CaseIterable, Codable, Identifiable {
    case improving
    case same
    case worse

    var id: String { rawValue }
    var label: String {
        switch self {
        case .improving: return "Improving"
        case .same: return "About the same"
        case .worse: return "Worse — consider backing off"
        }
    }
}

@Model
final class WeeklyCheckIn {
    @Attribute(.unique) var weekNumber: Int
    var weightChangeLb: Double?
    var avgSleepHours: Double?
    var sessionsCompleted: Int?
    var kneeTrendRaw: String
    var feltHard: String
    var feltGood: String
    var createdAt: Date

    init(
        weekNumber: Int,
        weightChangeLb: Double? = nil,
        avgSleepHours: Double? = nil,
        sessionsCompleted: Int? = nil,
        kneeTrend: KneeTrend = .same,
        feltHard: String = "",
        feltGood: String = "",
        createdAt: Date = .now
    ) {
        self.weekNumber = weekNumber
        self.weightChangeLb = weightChangeLb
        self.avgSleepHours = avgSleepHours
        self.sessionsCompleted = sessionsCompleted
        self.kneeTrendRaw = kneeTrend.rawValue
        self.feltHard = feltHard
        self.feltGood = feltGood
        self.createdAt = createdAt
    }

    var kneeTrend: KneeTrend {
        get { KneeTrend(rawValue: kneeTrendRaw) ?? .same }
        set { kneeTrendRaw = newValue.rawValue }
    }
}

// MARK: - Progress photo

/// A single progress-photo capture, shown in My Info's Progress Photos
/// section. Unlike `DailyLog`, `date` isn't unique — more than one capture
/// (e.g. front/side) on the same day is allowed.
@Model
final class ProgressPhoto {
    var date: Date
    @Attribute(.externalStorage) var photoData: Data
    var notes: String

    init(date: Date, photoData: Data, notes: String = "") {
        self.date = date
        self.photoData = photoData
        self.notes = notes
    }
}
