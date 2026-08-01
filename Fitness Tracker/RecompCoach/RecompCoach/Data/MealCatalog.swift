//
//  MealCatalog.swift
//  RecompCoach
//
//  Month 1 meal content (Day A/B/C rotation) from month1_meal_plan.md, plus the
//  logic that picks which meal to surface on the dashboard based on time of day
//  and which rotation day applies.
//

import Foundation

enum MealCatalog {

    // MARK: - Day A

    static let dayA = MealDay(
        id: "A",
        breakfast: MealDef(
            id: "a_breakfast", type: .breakfast, name: "Greek Yogurt Power Bowl",
            kcal: 585, proteinG: 50, carbG: 56, fatG: 19, fiberG: 7,
            ingredients: [
                "1.5 cups (340g) plain 2% Greek yogurt",
                "1/2 cup (40g) rolled oats",
                "1 tbsp (16g) peanut butter",
                "1/2 cup (75g) mixed berries"
            ],
            instructions: "Stir oats directly into cold yogurt (they soften in ~5 min) or microwave 45s if you prefer them warm. Top with peanut butter and berries.",
            prepMinutes: 3, cookMinutes: 1
        ),
        lunch: MealDef(
            id: "a_lunch", type: .lunch, name: "Chicken & Rice Bowl",
            kcal: 780, proteinG: 79, carbG: 77, fatG: 13, fiberG: 5,
            ingredients: [
                "8 oz (227g) chicken breast",
                "1.5 cups cooked white rice",
                "1 cup mixed vegetables (broccoli, bell pepper, snap peas)",
                "1 tsp olive oil",
                "1 tbsp low-sodium soy or teriyaki sauce"
            ],
            instructions: "Season chicken with salt/pepper/garlic powder, bake at 400°F for 20–25 min (or pan-sear ~6 min/side) until 165°F. Sauté vegetables in olive oil 4–5 min. Slice chicken over rice and vegetables, drizzle with sauce.",
            prepMinutes: 10, cookMinutes: 20
        ),
        dinner: MealDef(
            id: "a_dinner", type: .dinner, name: "Beef & Vegetable Stir Fry",
            kcal: 665, proteinG: 42, carbG: 60, fatG: 23, fiberG: 5,
            ingredients: [
                "6 oz (170g) 93% lean ground beef",
                "1 cup cooked white rice",
                "1.5 cups stir-fry vegetable mix",
                "1 tbsp neutral oil",
                "1–2 tbsp stir-fry sauce, garlic, ginger (optional)"
            ],
            instructions: "Brown beef in a hot pan ~6–8 min; drain excess fat if desired. Remove beef, add oil and vegetables, stir-fry 5–6 min until crisp-tender. Return beef, add sauce, toss 1–2 min. Serve over rice.",
            prepMinutes: 10, cookMinutes: 15
        )
    )

    // MARK: - Day B

    static let dayB = MealDay(
        id: "B",
        breakfast: MealDef(
            id: "b_breakfast", type: .breakfast, name: "Eggs, Toast & Avocado",
            kcal: 600, proteinG: 45, carbG: 38, fatG: 32, fiberG: 9,
            ingredients: [
                "3 whole eggs + 3 egg whites",
                "2 slices whole wheat toast",
                "1/2 avocado",
                "2 slices turkey bacon"
            ],
            instructions: "Scramble eggs/whites over medium-low heat. Cook turkey bacon per package (3–4 min per side). Toast bread, mash avocado on top.",
            prepMinutes: 5, cookMinutes: 10
        ),
        lunch: MealDef(
            id: "b_lunch", type: .lunch, name: "Tuna Quinoa Salad",
            kcal: 620, proteinG: 60, carbG: 47, fatG: 20, fiberG: 7,
            ingredients: [
                "2 cans (5oz each) tuna in water, drained",
                "1 cup cooked quinoa",
                "2 cups mixed greens",
                "1/2 cup cherry tomatoes, sliced cucumber",
                "1 tbsp olive oil + splash lemon or vinegar"
            ],
            instructions: "Cook quinoa per package (~15 min, or batch-cook for the week). Toss all ingredients together, dress just before eating.",
            prepMinutes: 10, cookMinutes: 0
        ),
        dinner: MealDef(
            id: "b_dinner", type: .dinner, name: "Sheet Pan Chicken Thighs",
            kcal: 690, proteinG: 51, carbG: 48, fatG: 33, fiberG: 8,
            ingredients: [
                "6 oz (2 medium) boneless, skinless chicken thighs",
                "1 medium potato, cubed",
                "1.5 cups broccoli florets",
                "1 tbsp olive oil, salt, pepper, garlic powder, paprika"
            ],
            instructions: "Toss potatoes and chicken in half the oil and seasoning, roast at 425°F for 15 min. Add broccoli tossed in remaining oil, roast another 12–15 min until chicken hits 165°F and potatoes are fork-tender.",
            prepMinutes: 10, cookMinutes: 30
        )
    )

    // MARK: - Day C

    static let dayC = MealDay(
        id: "C",
        breakfast: MealDef(
            id: "c_breakfast", type: .breakfast, name: "Protein Oats",
            kcal: 600, proteinG: 42, carbG: 72, fatG: 17, fiberG: 7,
            ingredients: [
                "1/2 cup rolled oats cooked in 1 cup 2% milk",
                "1 scoop whey protein (stir in once slightly cooled)",
                "1 banana, sliced",
                "1 tbsp peanut butter"
            ],
            instructions: "Simmer oats in milk 5 min, stirring occasionally. Remove from heat, stir in protein powder (don't boil it), top with banana and peanut butter.",
            prepMinutes: 2, cookMinutes: 5
        ),
        lunch: MealDef(
            id: "c_lunch", type: .lunch, name: "Turkey Chili with Rice",
            kcal: 725, proteinG: 52, carbG: 78, fatG: 19, fiberG: 10,
            ingredients: [
                "1.5 lb 93/7 ground turkey (makes 4–6 servings)",
                "2 cans kidney or black beans, drained",
                "1 can diced tomatoes",
                "1 diced onion, 2 cloves garlic",
                "Chili powder, cumin, paprika to taste",
                "1 cup cooked rice per serving",
                "Optional: 1oz shredded light cheese per serving"
            ],
            instructions: "Brown turkey with onion and garlic ~8 min. Add beans, tomatoes, and spices. Simmer 20–25 min, stirring occasionally. Serve over rice, top with cheese if using.",
            prepMinutes: 10, cookMinutes: 30
        ),
        dinner: MealDef(
            id: "c_dinner", type: .dinner, name: "Salmon, Sweet Potato & Asparagus",
            kcal: 515, proteinG: 39, carbG: 32, fatG: 24, fiberG: 7,
            ingredients: [
                "6 oz salmon fillet",
                "1 medium sweet potato",
                "1 cup asparagus",
                "1 tsp olive oil, salt, pepper, lemon"
            ],
            instructions: "Roast cubed sweet potato at 425°F for 20 min. Add salmon and asparagus (tossed in oil) to the same pan, roast another 12–15 min until salmon flakes easily.",
            prepMinutes: 8, cookMinutes: 20
        )
    )

    static let rotation: [MealDay] = [dayA, dayB, dayC]

    /// Which rotation day applies to a given 1-based program day (A→B→C→A…).
    static func day(forProgramDay programDay: Int) -> MealDay {
        rotation[(max(1, programDay) - 1) % rotation.count]
    }

    /// The meal to feature "right now" for `programDay` at `date`:
    /// the current/next window by time of day; after dinner rolls to tomorrow's breakfast.
    static func focusMeal(forProgramDay programDay: Int, at date: Date = .now)
        -> (meal: MealDef, rollsToTomorrow: Bool)
    {
        let hour = Calendar.current.component(.hour, from: date)
        if hour < MealType.breakfast.windowEndHour {
            return (day(forProgramDay: programDay).breakfast, false)
        } else if hour < MealType.lunch.windowEndHour {
            return (day(forProgramDay: programDay).lunch, false)
        } else if hour < MealType.dinner.windowEndHour {
            return (day(forProgramDay: programDay).dinner, false)
        } else {
            // Past dinner → tomorrow's breakfast.
            return (day(forProgramDay: programDay + 1).breakfast, true)
        }
    }
}
