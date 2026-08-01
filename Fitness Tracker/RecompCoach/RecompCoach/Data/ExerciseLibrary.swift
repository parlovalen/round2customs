//
//  ExerciseLibrary.swift
//  RecompCoach
//
//  Every unique exercise used anywhere across the 52-week program (all 7
//  phases, all 4 workout types, all 3 Phase 5+ specialization tracks),
//  deduplicated by id, with a hand-assigned muscle group for browsing.
//  Program content stays authored value types (see ProgramCatalog); this
//  just indexes it for the library UI.
//

import Foundation

enum MuscleGroup: String, CaseIterable, Identifiable {
    case legs = "Legs"
    case back = "Back"
    case chest = "Chest"
    case shoulders = "Shoulders"
    case arms = "Arms"
    case core = "Core"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .legs: return "figure.strengthtraining.traditional"
        case .back: return "figure.strengthtraining.functional"
        case .chest: return "figure.arms.open"
        case .shoulders: return "figure.boxing"
        case .arms: return "dumbbell.fill"
        case .core: return "figure.core.training"
        }
    }
}

enum ExerciseLibrary {

    /// Hand-assigned (not inferred from `targetMuscles` text) since the full
    /// program only has 40 unique exercises — precise beats a keyword guess.
    private static let muscleGroupsByExerciseId: [String: MuscleGroup] = [
        "ex_bench": .chest,
        "ex_bird_dog": .core,
        "ex_box_squat": .legs,
        "ex_bulgarian_split_squat": .legs,
        "ex_calf_raise_a": .legs,
        "ex_calf_raise_b": .legs,
        "ex_close_grip_bench": .arms,
        "ex_cs_row": .back,
        "ex_curl_a": .arms,
        "ex_db_flye": .chest,
        "ex_deceleration_step": .legs,
        "ex_face_pull": .shoulders,
        "ex_glute_kickback": .legs,
        "ex_goblet_squat": .legs,
        "ex_good_morning": .legs,
        "ex_hammer_curl": .arms,
        "ex_hip_thrust": .legs,
        "ex_incline_curl": .arms,
        "ex_incline_press": .chest,
        "ex_knee_raise": .core,
        "ex_lateral_band_walk_loaded": .legs,
        "ex_lateral_raise": .shoulders,
        "ex_leg_curl_band": .legs,
        "ex_ohp": .shoulders,
        "ex_pallof": .core,
        "ex_plank": .core,
        "ex_pull_through": .legs,
        "ex_pulldown": .back,
        "ex_pushdown": .arms,
        "ex_rdl_barbell": .legs,
        "ex_reverse_flye": .shoulders,
        "ex_sa_row": .back,
        "ex_seated_press": .shoulders,
        "ex_single_arm_chest_press": .chest,
        "ex_sl_rdl": .legs,
        "ex_spanish_squat": .legs,
        "ex_spanish_squat_b": .legs,
        "ex_step_up": .legs,
        "ex_wide_grip_pulldown": .back,
        "ex_walking_lunge": .legs
    ]

    /// A few exercises are authored under two different ids purely so the
    /// same movement can be logged as separate slots on different workout
    /// days (e.g. a calf-raise slot in lowerA vs. a separate one in lowerB).
    /// Canonicalizes those pairs to one id so the library shows one entry.
    private static let canonicalId: [String: String] = [
        "ex_calf_raise_b": "ex_calf_raise_a",
        "ex_spanish_squat_b": "ex_spanish_squat"
    ]

    static func muscleGroup(for exercise: ExerciseDef) -> MuscleGroup {
        let id = canonicalId[exercise.id] ?? exercise.id
        return muscleGroupsByExerciseId[id] ?? .core
    }

    /// Every unique exercise in the program, deduplicated by id (through
    /// `canonicalId`), sorted by name. Built by sampling one representative
    /// week per phase across every workout type and — for the Phase 5+
    /// track-dependent workouts — every specialization track.
    ///
    /// Dedup is by id, *not* name: several exercises (Box Squat, Front/Goblet
    /// Squat, Step-Up) keep the same id across phases but their name's
    /// parenthetical changes as the knee gate-check progression narrative
    /// advances ("pain-free depth" → "gated depth" → "depth per gate check"
    /// → "full depth if cleared") — deduping by name would show each of
    /// those as several separate entries.
    static let allExercises: [ExerciseDef] = {
        var seen = Set<String>()
        var result: [ExerciseDef] = []
        func add(_ defs: [ExerciseDef]) {
            for e in defs {
                let key = canonicalId[e.id] ?? e.id
                guard !seen.contains(key) else { continue }
                seen.insert(key)
                result.append(e)
            }
        }
        for type in WorkoutType.allCases {
            add(ProgramCatalog.workout(for: type, week: 1).exercises)
            add(ProgramCatalog.workout(for: type, week: 5).exercises)
            add(ProgramCatalog.workout(for: type, week: 13).exercises)
            add(ProgramCatalog.workout(for: type, week: 21).exercises)
            for track in SpecializationTrack.allCases {
                add(ProgramCatalog.workout(for: type, week: 33, track: track).exercises)
                add(ProgramCatalog.workout(for: type, week: 41, track: track).exercises)
            }
        }
        return result.sorted { $0.name < $1.name }
    }()

    static func exercises(in group: MuscleGroup) -> [ExerciseDef] {
        allExercises.filter { muscleGroup(for: $0) == group }
    }
}
