//
//  MealModels.swift
//  RecompCoach
//
//  Value types for meal plan content (authored, immutable) from month1_meal_plan.md.
//

import Foundation

/// A meal slot in the day. Each has a default time window used to pick the
/// "current / next" meal on the dashboard.
enum MealType: String, CaseIterable, Codable, Identifiable {
    case breakfast
    case lunch
    case dinner

    var id: String { rawValue }

    var display: String { rawValue.capitalized }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise"
        case .lunch: return "sun.max"
        case .dinner: return "moon.stars"
        }
    }

    /// Hour (0–24) at which this meal's window *ends*. After dinner's end we roll
    /// to the next day's breakfast.
    var windowEndHour: Int {
        switch self {
        case .breakfast: return 11   // breakfast until ~11:00
        case .lunch: return 15       // lunch until ~15:00
        case .dinner: return 21      // dinner until ~21:00
        }
    }
}

/// A single prescribed meal with macros and a full recipe.
struct MealDef: Identifiable, Codable, Hashable {
    let id: String
    let type: MealType
    let name: String
    let kcal: Int
    let proteinG: Int
    let carbG: Int
    let fatG: Int
    let fiberG: Int
    let ingredients: [String]
    let instructions: String
    let prepMinutes: Int
    let cookMinutes: Int

    var macroLine: String { "\(kcal) kcal · \(proteinG)g protein · \(carbG)g carb · \(fatG)g fat" }
}

/// One rotation day (A/B/C) of three meals.
struct MealDay: Identifiable {
    let id: String    // "A" / "B" / "C"
    let breakfast: MealDef
    let lunch: MealDef
    let dinner: MealDef

    func meal(_ type: MealType) -> MealDef {
        switch type {
        case .breakfast: return breakfast
        case .lunch: return lunch
        case .dinner: return dinner
        }
    }

    var all: [MealDef] { [breakfast, lunch, dinner] }
}
