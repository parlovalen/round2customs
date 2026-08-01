//
//  PublicExerciseCatalog.swift
//  RecompCoach
//
//  A general-purpose exercise reference library, imported from free-exercise-db
//  (github.com/yuhonas/free-exercise-db, Unlicense/public domain), bundled as
//  `exercises.json` and filtered down to weight-training-relevant categories
//  (strength, powerlifting, olympic weightlifting, strongman — excludes
//  stretching/cardio/plyometrics). This is reference-only content: unlike
//  `ExerciseLibrary` (the 40 exercises actually prescribed in the program),
//  these entries carry no prescription/tempo/RPE of their own — `asExerciseDef`
//  synthesizes generic hypertrophy defaults (3 × 8–12, 90s rest, RPE 7–8) so
//  they can still be swapped in mid-workout via `WorkoutDraft.swapExercise`,
//  which needs a real `ExerciseDef` with a parseable prescription.
//

import Foundation

/// One reference exercise from the imported public library.
struct ReferenceExerciseDef: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let equipment: String?
    let level: String
    let primaryMuscles: [String]
    let secondaryMuscles: [String]
    let instructions: [String]
    let imagePath: String?

    /// Synthesizes a program-shaped `ExerciseDef` so this can be swapped in
    /// mid-workout — generic hypertrophy defaults stand in for the prescription
    /// data this dataset doesn't carry; `instructions` becomes the coaching
    /// cues, since those genuinely are exercise-specific. Id is prefixed so it
    /// never collides with an authored `ex_...` program id.
    func asExerciseDef() -> ExerciseDef {
        let muscles = (primaryMuscles + secondaryMuscles).map { $0.capitalized }
        return ExerciseDef(
            id: "ref_\(id)",
            name: name,
            kind: .strength,
            prescription: "3 × 8–12",
            tempo: "Controlled",
            restSeconds: 90,
            rpe: "7–8",
            targetMuscles: muscles,
            commonMistakes: [],
            coachingCues: instructions,
            videoKeywords: name,
            beginnerModification: "Reduce load or range of motion until the movement feels controlled.",
            advancedProgression: "Add load, slow the tempo, or add a pause once form is consistent."
        )
    }
}

enum PublicExerciseCatalog {

    /// Maps free-exercise-db's muscle vocabulary onto the app's own
    /// `MuscleGroup` buckets, so the same filter chips work across both
    /// the program library and this one.
    private static let muscleGroupByName: [String: MuscleGroup] = [
        "abdominals": .core,
        "abductors": .legs,
        "adductors": .legs,
        "biceps": .arms,
        "calves": .legs,
        "chest": .chest,
        "forearms": .arms,
        "glutes": .legs,
        "hamstrings": .legs,
        "lats": .back,
        "lower back": .back,
        "middle back": .back,
        "neck": .shoulders,
        "quadriceps": .legs,
        "shoulders": .shoulders,
        "traps": .shoulders,
        "triceps": .arms
    ]

    /// Every imported exercise, sorted by name. Decoded once from the bundled
    /// `exercises.json` resource.
    static let all: [ReferenceExerciseDef] = {
        guard
            let url = Bundle.main.url(forResource: "exercises", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let decoded = try? JSONDecoder().decode([ReferenceExerciseDef].self, from: data)
        else { return [] }
        return decoded.sorted { $0.name < $1.name }
    }()

    /// First primary muscle wins; falls back to `.core` for anything unmapped.
    static func muscleGroup(for ex: ReferenceExerciseDef) -> MuscleGroup {
        for muscle in ex.primaryMuscles {
            if let group = muscleGroupByName[muscle] { return group }
        }
        return .core
    }

    static func exercises(in group: MuscleGroup) -> [ReferenceExerciseDef] {
        all.filter { muscleGroup(for: $0) == group }
    }

    /// Raw GitHub-hosted photo for this exercise, from the same public dataset.
    static func imageURL(for ex: ReferenceExerciseDef) -> URL? {
        guard let path = ex.imagePath else { return nil }
        return URL(string: "https://raw.githubusercontent.com/yuhonas/free-exercise-db/main/exercises/\(path)")
    }
}
