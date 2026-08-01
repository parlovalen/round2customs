//
//  ImageProvider.swift
//  RecompCoach
//
//  Resolves a remote photo URL for each exercise and meal using a free
//  keyword image service (loremflickr, CC-licensed Flickr photos, no API key).
//  A deterministic `lock` value keeps each item's image stable across launches.
//

import Foundation

enum ImageProvider {

    private static let base = "https://loremflickr.com"

    /// Keyword search terms per exercise id (best-match photo subjects).
    /// Only a fallback now — every exercise has a dedicated Pexels photo in
    /// `exercisePexelsID` below, so this map is unreachable in practice but
    /// kept as a safety net if an id is ever added without one.
    private static let exerciseKeywords: [String: String] = [
        "ex_rdl_barbell": "deadlift,gym",
        "ex_box_squat": "squat,gym",
        "ex_hip_thrust": "barbell,glutes",
        "ex_spanish_squat": "fitness,squat",
        "ex_calf_raise_a": "gym,legs",
        "ex_pallof": "cable,core",
        "ex_bench": "bench,press",
        "ex_cs_row": "dumbbell,row",
        "ex_seated_press": "dumbbell,shoulder",
        "ex_pulldown": "pullup,gym",
        "ex_curl_a": "dumbbell,curl",
        "ex_pushdown": "triceps,gym",
        "ex_plank": "plank,fitness",
        "ex_goblet_squat": "goblet,squat",
        "ex_sl_rdl": "dumbbell,deadlift",
        "ex_step_up": "box,gym",
        "ex_calf_raise_b": "gym,legs",
        "ex_spanish_squat_b": "fitness,squat",
        "ex_bird_dog": "core,exercise",
        "ex_ohp": "overhead,press",
        "ex_incline_press": "dumbbell,bench",
        "ex_sa_row": "dumbbell,row",
        "ex_face_pull": "cable,gym",
        "ex_hammer_curl": "dumbbell,curl",
        "ex_knee_raise": "abs,gym"
    ]

    /// Hand-picked professional (Unsplash) studio photos per session, matched to
    /// the day's muscle-group focus. Direct CDN URLs — stable and hotlink-allowed.
    private static let workoutImageURLs: [WorkoutType: String] = [
        .lowerA: "https://images.unsplash.com/photo-1646495001290-39103b31873a", // leg machine
        .lowerB: "https://images.unsplash.com/photo-1623874307886-443c99baf1ed", // squat racks
        .upperA: "https://images.unsplash.com/photo-1581009137042-c552e485697a", // chest / torso
        .upperB: "https://images.unsplash.com/photo-1704223523318-116d02723c05"  // shoulder work
    ]

    /// Full image URLs for exercises whose best photo lives outside Pexels.
    /// Checked before the Pexels-ID map below.
    private static let exerciseImageURLFull: [String: String] = [
        "ex_bird_dog": "https://static.nike.com/a/images/f_auto,cs_srgb/w_1536,c_limit/42669341-d71d-4660-b5f2-c62a50e69b46/why-you-should-add-the-bird-dog-exercise-to-your-workout-routine-according-to-trainers.jpg"
    ]

    /// Curated Pexels photo IDs per exercise — authentic gym action shots that
    /// match the "person performing the lift" style. Some near-identical
    /// movements intentionally share a photo. Falls back to keyword search below.
    private static let exercisePexelsID: [String: Int] = [
        "ex_rdl_barbell": 13822300,   // Romanian deadlift / hinge
        "ex_box_squat": 13106591,     // barbell back squat
        "ex_hip_thrust": 4534632,     // glute bridge / hip thrust
        "ex_spanish_squat": 6740054,  // wall-sit isometric hold
        "ex_calf_raise_a": 13965339,  // calf raise
        "ex_pallof": 5327505,         // cable core
        "ex_bench": 3837781,          // barbell bench press
        "ex_cs_row": 12890888,        // chest-supported dumbbell row (incline bench)
        "ex_seated_press": 7289370,   // dumbbell shoulder press
        "ex_pulldown": 31329758,      // lat pulldown machine (back view)
        "ex_curl_a": 3926644,         // dumbbell curl
        "ex_pushdown": 13616289,      // cable triceps pushdown
        "ex_plank": 4047105,          // plank / core
        "ex_goblet_squat": 1552249,   // front-loaded squat
        "ex_sl_rdl": 841125,          // single-leg deadlift / hinge
        "ex_step_up": 13896897,       // step-up onto box
        "ex_calf_raise_b": 13965339,  // calf raise
        "ex_spanish_squat_b": 6740054, // wall-sit isometric hold
        "ex_bird_dog": 4047105,       // core
        "ex_ohp": 13106581,           // overhead press
        "ex_incline_press": 29526383, // incline dumbbell press
        "ex_sa_row": 2247179,         // single-arm dumbbell row
        "ex_face_pull": 29084391,     // standing cable pull
        "ex_hammer_curl": 3763115,    // dumbbell curl
        "ex_knee_raise": 8520073,     // hanging leg raise
        "ex_lateral_raise": 29793977, // dumbbell side/lateral raise (was sharing seated_press's photo)
        "ex_bulgarian_split_squat": 4587373,   // rear-foot-elevated split squat
        "ex_close_grip_bench": 3916762,        // close/narrow-grip barbell press
        "ex_db_flye": 7289245,                 // dumbbell chest fly on bench
        "ex_deceleration_step": 7675403,       // single-leg box step/landing
        "ex_glute_kickback": 13965338,         // glute kickback machine
        "ex_good_morning": 13106612,           // barbell hip-hinge
        "ex_incline_curl": 5327483,            // seated dumbbell curl
        "ex_lateral_band_walk_loaded": 6339637, // resistance band leg work
        "ex_leg_curl_band": 6539840,           // leg curl machine
        "ex_pull_through": 34137915,           // cable machine hip-hinge work
        "ex_reverse_flye": 5327464,            // dumbbell rear-delt raise
        "ex_single_arm_chest_press": 20418607, // single-arm cable press
        "ex_wide_grip_pulldown": 17706037,     // wide-grip lat pulldown
        "ex_walking_lunge": 14673249           // dumbbell walking lunge
    ]

    /// Keyword search terms per meal id.
    private static let mealKeywords: [String: String] = [
        "a_breakfast": "yogurt,berries",
        "a_lunch": "chicken,rice",
        "a_dinner": "beef,stirfry",
        "b_breakfast": "eggs,avocado,toast",
        "b_lunch": "tuna,salad",
        "b_dinner": "chicken,roast",
        "c_breakfast": "oatmeal,banana",
        "c_lunch": "chili,rice",
        "c_dinner": "salmon,vegetables"
    ]

    // MARK: - Public

    static func exerciseURL(_ ex: ExerciseDef, width: Int = 1000, height: Int = 560) -> URL? {
        if let full = exerciseImageURLFull[ex.id] {
            return URL(string: full)
        }
        if let id = exercisePexelsID[ex.id] {
            return URL(string: "https://images.pexels.com/photos/\(id)/pexels-photo-\(id).jpeg?auto=compress&cs=tinysrgb&fit=crop&w=\(width)&h=\(height)")
        }
        let keywords = exerciseKeywords[ex.id] ?? "gym,workout"
        return url(keywords: keywords, seed: ex.id, width: width, height: height)
    }

    static func mealURL(_ meal: MealDef, width: Int = 600, height: Int = 400) -> URL? {
        let keywords = mealKeywords[meal.id] ?? "food,healthy"
        return url(keywords: keywords, seed: meal.id, width: width, height: height)
    }

    static func workoutURL(_ type: WorkoutType, width: Int = 800, height: Int = 500) -> URL? {
        guard let base = workoutImageURLs[type] else { return nil }
        return URL(string: "\(base)?w=\(width)&h=\(height)&fit=crop&crop=entropy&q=80&auto=format")
    }

    /// Photo for a scheduled rest/soccer day. One stable, hand-picked image —
    /// there's no per-day content to vary it by, unlike meals/exercises.
    static func restDayURL() -> URL? {
        URL(string: "https://images.stockcake.com/public/0/a/7/0a794f50-e53c-4067-859d-0607c544cd9a_large/nighttime-soccer-field-stockcake.jpg")
    }

    // MARK: - Private

    private static func url(keywords: String, seed: String, width: Int, height: Int) -> URL? {
        let lock = stableLock(seed)
        return URL(string: "\(base)/\(width)/\(height)/\(keywords)?lock=\(lock)")
    }

    /// Deterministic small integer from a string (djb2), so a given item always
    /// resolves to the same photo.
    private static func stableLock(_ s: String) -> Int {
        var hash: UInt64 = 5381
        for byte in s.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        return Int(hash % 100_000)
    }
}
