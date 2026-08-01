# Handoff Brief — 52-Week Recomp Coaching App (iOS)

This is the complete content and design package for a native iOS app: a personalized, year-long bodybuilding recomposition coach with Apple Health integration. Everything in this folder was built and reviewed with the end user before this handoff — it's ready to build from, not a draft.

## Who this is for
42-year-old male, 5'11", 187 lb, ~22% body fat, true beginner to structured lifting. Goal: body recomposition. Trains 4 days/week with a full home gym (barbell, rack, adjustable bench, pull-up bar). Plays soccer 2-3x/week (this matters — it replaces the need for dedicated cardio programming and is a running factor in knee-load management). Has mild patellar tendonitis, which shapes exercise selection throughout. Owns an Apple Watch. Sleeps ~12am-7am. No dietary restrictions.

## File Index

| File | Contents |
|---|---|
| `phase1_foundation_program.md` | Weeks 1-4. Full workouts (warm-up → cooldown), profile, nutrition targets/reasoning, weekly schedule, patellar tendon protocol, sleep/habit notes |
| `phase2_hypertrophy1_program.md` | Weeks 5-12 |
| `phase3_strength_foundation_program.md` | Weeks 13-20 |
| `phase4_hypertrophy2_program.md` | Weeks 21-32 (longest phase; includes the 6-month recomp reassessment) |
| `phase5_specialization_program.md` | Weeks 33-40 (choose-your-track: Arms/Shoulders, Posterior Chain, or Athletic/Soccer Carryover) |
| `phase6_advanced_growth_program.md` | Weeks 41-48 (introduces top-set + back-off set structure) |
| `phase7_yearend_assessment_planning.md` | Weeks 49-52: final deload, full-year assessment, Year 2 decision framework |
| `month1_meal_plan.md` | 3 rotating daily meal templates matched to macros, full recipes, shopping list, budget/quick/family/eating-out notes |
| `supplements_guide.md` | Evidence-graded supplement recommendations (creatine, whey, vitamin D, fish oil, caffeine, electrolytes) |
| `sleep_recovery_protocol.md` | Wind-down/morning routines, sleep hygiene checklist, recovery score formula, sleep-by-training-intensity guidance |
| `habit_progression_yearlong.md` | Month-by-month habit rollout for the full year, with rationale |
| `education_curriculum.md` | 12-month education topic map + 3 fully written sample lessons (Month 1) |
| `motivation_behavioral_system.md` | Trigger logic + sample message bank for notifications/in-app encouragement |
| `cardio_and_mobility.md` | Cardio approach (soccer-integrated, no redundant cardio days) + daily/weekly mobility routines |
| `app_data_model_example.json` | **Reference schema** — Phase 1 fully modeled as the pattern (userProfile, nutritionTargets, trainingProgram → phases → workouts → exercises, trackingSchema, healthKitMapping). Phases 2-7 are NOT yet in JSON — see note below. |
| `training_tracker.html` | Working browser prototype (HTML/JS) of the logging + tracking UX: daily log, workout log, weekly check-in with auto-fill, history with weight/knee-pain trend charts, knee-status meter. **This is a UX/interaction reference, not something to literally port** — it proves out the data flow and the feature set, but the real app should be native SwiftUI, not a wrapped web view. |

## What Claude Code should do first
1. **Extend `app_data_model_example.json` into complete SwiftData models** covering all 7 phases — this is mechanical extraction from the phase markdown files, not a design decision, so it's a better first task for you than for hand-written JSON.
2. **Use `training_tracker.html` as the reference for the logging/tracking feature set and data relationships** (daily log, workout log with per-exercise weight/reps/RPE, weekly check-in with auto-fill from logged data, knee-status trend meter) — rebuild natively, don't port the HTML.
3. **Recommended build order:** ship Phase 1's workouts + the core logging/tracking/dashboard first (a real, working MVP), then layer in Phases 2-7 content, HealthKit sync, notifications, and the education/motivation systems — rather than building the entire spec before anything runs on a device.

## HealthKit scope (from the JSON model)
- **Import:** body weight, steps, active energy burned, heart rate, resting heart rate, HRV, sleep analysis, VO2 max
- **Export:** workouts, body weight, dietary energy/protein/carbs/fat, dietary water

## Open decisions not yet made (need the user's input during build, not assumptions)
- App Store distribution vs. personal/sideloaded use
- Whether an Apple Watch companion app is in scope for v1 or later
- Cloud sync vs. on-device only
- Exact notification delivery mechanism/timing (the logic and copy exist in `motivation_behavioral_system.md`, but scheduling implementation is a build decision)
- Barcode scanner for food logging — placeholder was requested in the original spec but no implementation detail exists yet

## Known gaps (by design, not oversight)
- Meal plans/recipes only exist for Month 1 — later months reuse the same templates with adjusted portions per the nutrition adjustment rule, unless/until new recipes are requested
- Education lessons are fully written for Month 1 only; months 2-12 have topics assigned but not full lesson text (written on request as each month arrives)
- The JSON data model is fully fleshed out for Phase 1 only, as noted above
