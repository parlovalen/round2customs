//
//  ProgramModels.swift
//  RecompCoach
//
//  Value types describing the *program definition* (immutable reference content).
//  These are intentionally NOT SwiftData @Model types: the program is authored
//  content that ships with the app, not user-mutable data. User-generated data
//  (logs, check-ins, profile) lives in DataModels.swift as SwiftData models.
//
//  Phase 1 (Foundation, weeks 1–4) is modeled in full detail in ProgramCatalog.
//  Later phases follow the same shape and get filled in as they're built.
//

import Foundation

/// One of the four training sessions in the Phase 1 split.
enum WorkoutType: String, CaseIterable, Codable, Identifiable {
    case lowerA = "lower_a"
    case upperA = "upper_a"
    case lowerB = "lower_b"
    case upperB = "upper_b"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .lowerA: return "Legs 1"
        case .upperA: return "Upper Body 1"
        case .lowerB: return "Legs 2"
        case .upperB: return "Upper Body 2"
        }
    }

    /// True for the two lower-body sessions (used for knee-load sequencing hints).
    var isLower: Bool { self == .lowerA || self == .lowerB }
}

/// How an exercise is logged — a loaded strength movement vs. a timed isometric hold.
enum ExerciseKind: String, Codable {
    case strength
    case isometric
}

/// A single prescribed exercise within a workout.
struct ExerciseDef: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let kind: ExerciseKind
    /// Prescription as shown to the user, e.g. "3 × 8" or "3 × 30–45s hold".
    let prescription: String
    let tempo: String
    let restSeconds: Int
    /// Target RPE as text so ranges like "6–7" are preserved.
    let rpe: String
    let targetMuscles: [String]
    let commonMistakes: [String]
    let coachingCues: [String]
    let videoKeywords: String
    let beginnerModification: String
    let advancedProgression: String
}

/// A full workout: warm-up context plus the prescribed exercises.
struct WorkoutDef: Identifiable, Codable, Hashable {
    var id: String { type.rawValue }
    let type: WorkoutType
    let warmup: String
    let mobility: String
    let activation: String
    let exercises: [ExerciseDef]
    let cooldown: String

    var name: String { type.displayName }
}

/// A training phase spanning a range of program weeks.
struct PhaseDef: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let weekStart: Int
    let weekEnd: Int
    let goals: [String]
    let progressionRule: String
    /// Program weeks within this phase that are deload/assessment weeks.
    let deloadWeeks: [Int]

    func contains(week: Int) -> Bool { week >= weekStart && week <= weekEnd }
    func isDeload(week: Int) -> Bool { deloadWeeks.contains(week) }
}

/// Phase 5's choose-your-focus specialization track (see phase5_specialization_program.md).
/// The user picks one based on what their monthly assessment shows is lagging;
/// Phase 6 continues whichever track served them best.
enum SpecializationTrack: String, CaseIterable, Codable, Identifiable {
    case armsShoulders = "arms_shoulders"
    case posteriorChain = "posterior_chain"
    case athleticPerformance = "athletic_performance"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .armsShoulders: return "Arms & Shoulders"
        case .posteriorChain: return "Posterior Chain & Glutes"
        case .athleticPerformance: return "Athletic Performance"
        }
    }

    var summary: String {
        switch self {
        case .armsShoulders:
            return "Upper arms/shoulders lagging relative to chest/back, or just want more definition there."
        case .posteriorChain:
            return "Glutes/hamstrings lagging relative to quads/upper body."
        case .athleticPerformance:
            return "Knee has been consistently clean and you want direct soccer carryover — cutting, deceleration, single-leg stability."
        }
    }
}
