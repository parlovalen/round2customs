//
//  ProgramCatalog.swift
//  RecompCoach
//
//  The authored program content. Phase 1 (Foundation, weeks 1–4) is modeled in
//  full from phase1_foundation_program.md. Phases 2–7 will be appended here in
//  the same shape as they're built out.
//

import Foundation

enum ProgramCatalog {

    static let totalWeeks = 52

    static let phase1 = PhaseDef(
        id: "phase_1",
        name: "Foundation",
        weekStart: 1,
        weekEnd: 4,
        goals: [
            "Learn correct movement patterns before adding meaningful load",
            "Build baseline training tolerance without excessive soreness",
            "Begin the daily patellar tendon loading protocol",
            "Establish the habit of showing up 4×/week and logging every session"
        ],
        progressionRule:
            "RPE 6–7 throughout (3–4 reps in reserve). Wk1 learn the movements light. "
            + "Wk2–3 add ~5% on main lifts if form was clean and knee pain ≤2/10. "
            + "Wk4 is a light/assessment week — drop ~1 set per exercise, keep load, "
            + "focus on quality before Phase 2 adds volume.",
        deloadWeeks: [4]
    )

    static let phase2 = PhaseDef(
        id: "phase_2",
        name: "Hypertrophy 1",
        weekStart: 5,
        weekEnd: 12,
        goals: [
            "Increase training volume moderately now that movement patterns are established",
            "Add exercise variety to keep driving adaptation and reduce staleness",
            "Gate check before increasing squat depth: knee pain ≤2/10 with no next-morning soreness for 2+ consecutive weeks",
            "Continue the daily/near-daily patellar tendon isometric protocol — it doesn't pause for any phase"
        ],
        progressionRule:
            "Wk5 returns to RPE 7 at higher volume (main lifts 3→4 sets; accessories 3×10–15). "
            + "Wk6–7 add ~5% when the top of the rep range is hit at RPE ≤7. "
            + "Wk8 deload — cut sets ~40%, RPE 5–6, full assessment + knee gate check. "
            + "Wk9 resumes from Wk7 numbers +5%. Wk10–11 standard progression. "
            + "Wk12 deload — same structure; also decides Phase 3 readiness.",
        deloadWeeks: [8, 12]
    )

    static let phase3 = PhaseDef(
        id: "phase_3",
        name: "Strength Foundation",
        weekStart: 13,
        weekEnd: 20,
        goals: [
            "Shift from higher-rep hypertrophy work toward heavier loads and lower reps (5–8) on main lifts",
            "Keep accessory work in the 8–15 range to keep supporting growth while main lifts drive strength",
            "If knee status has been clean through two checkpoints, gradually increase squat depth toward full range",
            "Continue the tendon isometric protocol unchanged — it matters more as loads climb, not less"
        ],
        progressionRule:
            "Wk13 introduces lower rep ranges (5–8) on main lifts at RPE 7 for that range — let RPE guide the jump, not ego. "
            + "Wk14–15 add ~5% when the top of the rep range is hit at RPE ≤7. "
            + "Wk16 deload (1-month mark) — cut sets ~40%, load ~10–15% lower, full review + knee check. "
            + "Wk17 resumes from Wk15 numbers +5%. Wk18–19 continue, RPE up to 8 by Wk19. "
            + "Wk20 deload — also decides readiness for Phase 4's higher volume, or whether a stabilization week is warranted first.",
        deloadWeeks: [16, 20]
    )

    static let phase4 = PhaseDef(
        id: "phase_4",
        name: "Hypertrophy 2",
        weekStart: 21,
        weekEnd: 32,
        goals: [
            "Maximum sustainable training volume for the year — most of the year's muscle growth should accumulate here",
            "Return to 8–15 rep ranges on main lifts, at heavier absolute loads than Phase 2 thanks to the Phase 3 strength base",
            "This phase spans the 6-month mark (~Wk26) — use the Wk24 or Wk28 checkpoint to decide if pure recomp is still working, or if a short lean-bulk/mini-cut block makes more sense",
            "Continue the tendon protocol unchanged"
        ],
        progressionRule:
            "Wk21 returns to 8–12 rep main lifts at RPE 7, loads reflecting the Phase 3 strength gains. "
            + "Wk22–23 add ~5% when the top of the rep range is hit at RPE ≤7. "
            + "Wk24 deload (6-month checkpoint) — full review of the 6-month trend, not just the last month. "
            + "Wk25–27 resume from Wk23 numbers. Wk28 deload — standard structure. "
            + "Wk29–31 continue, pushing RPE 8 on main lifts by Wk31. "
            + "Wk32 deload — also decides readiness for Phase 5's Specialization, the earliest point dynamic lower-body work returns if the knee has been clean.",
        deloadWeeks: [24, 28, 32]
    )

    static let phase5 = PhaseDef(
        id: "phase_5",
        name: "Specialization",
        weekStart: 33,
        weekEnd: 40,
        goals: [
            "Core 4-day Upper/Lower structure continues unchanged, main lifts stay in a 6–10 rep hypertrophy-strength blend",
            "2 exercise slots per session are swapped for a chosen specialization track (Arms & Shoulders, Posterior Chain & Glutes, or Athletic Performance)",
            "If Wk32+ showed sustained clean knee status, this is the earliest point to reintroduce light lateral movement, controlled deceleration, and fuller-range squat/lunge work (Track C)",
            "Choose the track from what the Wk32 assessment actually shows is lagging — can also split 4 weeks on one track, 4 on another"
        ],
        progressionRule:
            "Wk33–35 standard progression on core lifts (+5% when top of rep range hit at RPE ≤7); specialization exercises start conservative (RPE 6–7) as newer movement patterns. "
            + "Wk36 deload — standard structure. "
            + "Wk37–39 continue progression on both core and specialization lifts. "
            + "Wk40 deload — also decides whether Phase 6's Advanced Growth is appropriate, or whether another specialization block would serve better first.",
        deloadWeeks: [36, 40]
    )

    static let phase6 = PhaseDef(
        id: "phase_6",
        name: "Advanced Growth",
        weekStart: 41,
        weekEnd: 48,
        goals: [
            "Highest combined volume + intensity block of the year, appropriate with ~9 months of training experience",
            "Introduce top-set + back-off-set structure on main lifts",
            "Continue whichever Phase 5 specialization track served best, or blend elements of two",
            "Only run at full intensity if recovery markers (sleep, soreness, mood, knee status) have been solid through Phase 5 — otherwise scale back to straight sets at Phase 4/5 volume"
        ],
        progressionRule:
            "Wk41–43 introduce the top-set + back-off structure (1 top set at prescribed reps/RPE, 2–3 back-off sets at ~85–90% of that weight, RPE 6–7), pushing the top set to RPE 8 by Wk43. "
            + "Wk44 deload — standard structure. "
            + "Wk45–47 continue the pattern, top set reaching RPE 8–9 by Wk47 — the closest to true effort all year. "
            + "Wk48 deload — final checkpoint before the Wk49–52 wind-down and Year 2 planning.",
        deloadWeeks: [44, 48]
    )

    static let phase7 = PhaseDef(
        id: "phase_7",
        name: "Wind-Down & Year 2 Planning",
        weekStart: 49,
        weekEnd: 52,
        goals: [
            "Wk49 deload — cut sets ~40–50% across all four workouts, load moderate, RPE 5–6. Nothing new introduced.",
            "Wk50 active recovery / exploration — lighter still, RPE 5–6, try one exercise variation you haven't done all year out of curiosity",
            "Wk51 full-year assessment — compare Wk1 vs Wk51 on weight, measurements, photos, strength at matched rep ranges, knee status, sleep consistency, and which habits actually stuck",
            "Wk52 Year 2 planning — decide cut vs. lean bulk vs. continued recomp based on the Wk51 data, since the beginner \"newbie gains\" window typically closes in the 6–12 month range"
        ],
        progressionRule:
            "No new exercises this block — Wk49–50 reuse Phase 6's workouts at reduced volume/intensity. "
            + "Wk51–52 are assessment and planning weeks, not new training content.",
        deloadWeeks: [49]
    )

    /// All phases known to the app, covering the full 52 weeks.
    static let phases: [PhaseDef] = [phase1, phase2, phase3, phase4, phase5, phase6, phase7]

    /// The phase containing `week` (clamped to the first/last phase if out of range).
    static func phase(forWeek week: Int) -> PhaseDef {
        phases.first { $0.contains(week: week) } ?? (week < 1 ? phase1 : phase7)
    }

    // MARK: - Phase 1 workouts

    static let lowerA = WorkoutDef(
        type: .lowerA,
        warmup: "5 min easy bike or rower",
        mobility: "Ankle dorsiflexion rocks 2×10/side · 90/90 hip switches 2×8/side",
        activation: "Glute bridges 2×12 · banded lateral walks 2×10 steps/side",
        exercises: [
            ExerciseDef(
                id: "ex_rdl_barbell",
                name: "Barbell Romanian Deadlift",
                kind: .strength,
                prescription: "3 × 8",
                tempo: "3-1-1-0",
                restSeconds: 90,
                rpe: "6–7",
                targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                videoKeywords: "Romanian deadlift form tutorial",
                beginnerModification: "Use dumbbells, reduce range of motion",
                advancedProgression: "Deficit RDL, heavier barbell load"
            ),
            ExerciseDef(
                id: "ex_box_squat",
                name: "Box Squat (pain-free depth only)",
                kind: .strength,
                prescription: "3 × 8",
                tempo: "3-1-1-0",
                restSeconds: 120,
                rpe: "6–7",
                targetMuscles: ["Quads", "Glutes", "Adductors"],
                commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                videoKeywords: "box squat tutorial beginner",
                beginnerModification: "Reduce depth further, bodyweight only",
                advancedProgression: "Increase depth gradually as tolerated, add load"
            ),
            ExerciseDef(
                id: "ex_hip_thrust",
                name: "Barbell Hip Thrust",
                kind: .strength,
                prescription: "3 × 10",
                tempo: "2-1-2-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Glutes", "Hamstrings"],
                commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                videoKeywords: "barbell hip thrust form",
                beginnerModification: "Bodyweight or single-leg glute bridge",
                advancedProgression: "Add pause at top, increase load"
            ),
            ExerciseDef(
                id: "ex_spanish_squat",
                name: "Spanish Squat Isometric Hold",
                kind: .isometric,
                prescription: "3 × 30–45s hold",
                tempo: "Isometric",
                restSeconds: 60,
                rpe: "6 — tendon work, not max effort",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                videoKeywords: "Spanish squat patellar tendon",
                beginnerModification: "Reduce hold time or band tension",
                advancedProgression: "Add light dumbbell hold across chest"
            ),
            ExerciseDef(
                id: "ex_calf_raise_a",
                name: "Standing Calf Raise",
                kind: .strength,
                prescription: "3 × 12–15",
                tempo: "2-1-2-1",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Bouncing", "Partial range"],
                coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                videoKeywords: "standing calf raise proper form",
                beginnerModification: "Bodyweight only",
                advancedProgression: "Add barbell load"
            ),
            ExerciseDef(
                id: "ex_pallof",
                name: "Pallof Press",
                kind: .strength,
                prescription: "2 × 10/side",
                tempo: "Controlled",
                restSeconds: 45,
                rpe: "6",
                targetMuscles: ["Core (anti-rotation)"],
                commonMistakes: ["Letting hips rotate"],
                coachingCues: ["Brace your core", "Resist the band pulling you"],
                videoKeywords: "Pallof press tutorial",
                beginnerModification: "Lighter band",
                advancedProgression: "Half-kneeling variation"
            )
        ],
        cooldown: "Quad + hamstring static stretch (30s each) · gentle foam roll around (not on) the patellar tendon · 2 min diaphragmatic breathing"
    )

    static let upperA = WorkoutDef(
        type: .upperA,
        warmup: "5 min bike or rower · arm circles · band pull-aparts 2×15",
        mobility: "Thoracic rotations 2×8/side · shoulder dislocates with band 2×10",
        activation: "Scap push-ups 2×10 · band pull-aparts 2×15",
        exercises: [
            ExerciseDef(
                id: "ex_bench",
                name: "Barbell Bench Press",
                kind: .strength,
                prescription: "3 × 8–10",
                tempo: "3-1-1-0",
                restSeconds: 90,
                rpe: "6–7",
                targetMuscles: ["Chest", "Triceps", "Front delts"],
                commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                videoKeywords: "barbell bench press form",
                beginnerModification: "Dumbbell floor press",
                advancedProgression: "Add pause at chest"
            ),
            ExerciseDef(
                id: "ex_cs_row",
                name: "Chest-Supported DB Row",
                kind: .strength,
                prescription: "3 × 10",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Lats", "Mid-back", "Biceps"],
                commonMistakes: ["Using momentum", "Shrugging shoulders"],
                coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                videoKeywords: "chest supported dumbbell row",
                beginnerModification: "Reduce load, seated band row",
                advancedProgression: "Single-arm variation"
            ),
            ExerciseDef(
                id: "ex_seated_press",
                name: "Seated DB Shoulder Press",
                kind: .strength,
                prescription: "3 × 8–10",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Shoulders", "Triceps"],
                commonMistakes: ["Excessive lower back arch"],
                coachingCues: ["Brace core", "Press straight overhead"],
                videoKeywords: "seated dumbbell shoulder press",
                beginnerModification: "Reduce load, use seated back support",
                advancedProgression: "Standing variation"
            ),
            ExerciseDef(
                id: "ex_pulldown",
                name: "Assisted Pull-up / Lat Pulldown",
                kind: .strength,
                prescription: "3 × 8–10",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Lats", "Biceps"],
                commonMistakes: ["Using momentum", "Partial range"],
                coachingCues: ["Lead with the chest", "Full stretch at the top"],
                videoKeywords: "assisted pull up progression",
                beginnerModification: "Band-assisted",
                advancedProgression: "Add weight, reduce assistance"
            ),
            ExerciseDef(
                id: "ex_curl_a",
                name: "DB Bicep Curl",
                kind: .strength,
                prescription: "2 × 12",
                tempo: "2-0-2-0",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Biceps"],
                commonMistakes: ["Swinging body", "Elbows drifting forward"],
                coachingCues: ["Elbows pinned to sides"],
                videoKeywords: "dumbbell bicep curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Alternate curl, slower eccentric"
            ),
            ExerciseDef(
                id: "ex_pushdown",
                name: "Band/Cable Triceps Pushdown",
                kind: .strength,
                prescription: "2 × 12–15",
                tempo: "2-0-2-0",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Triceps"],
                commonMistakes: ["Flaring elbows out"],
                coachingCues: ["Elbows locked at sides"],
                videoKeywords: "triceps pushdown form",
                beginnerModification: "Overhead DB extension",
                advancedProgression: "Add load"
            ),
            ExerciseDef(
                id: "ex_plank",
                name: "Plank",
                kind: .isometric,
                prescription: "2 × 30–45s",
                tempo: "Isometric",
                restSeconds: 45,
                rpe: "6",
                targetMuscles: ["Core"],
                commonMistakes: ["Hips sagging or piking"],
                coachingCues: ["Straight line head to heel"],
                videoKeywords: "plank proper form",
                beginnerModification: "Knee plank",
                advancedProgression: "Add weight on back"
            )
        ],
        cooldown: "Chest/shoulder doorway stretch · lat stretch · 2 min breathing"
    )

    static let lowerB = WorkoutDef(
        type: .lowerB,
        warmup: "5 min bike · ankle rocks · hip circles",
        mobility: "Hip flexor stretch 2×30s/side",
        activation: "Wall sit isometric 2×20–30s · banded clamshells 2×12/side",
        exercises: [
            ExerciseDef(
                id: "ex_goblet_squat",
                name: "Front or Goblet Squat (pain-free depth)",
                kind: .strength,
                prescription: "3 × 8",
                tempo: "3-1-1-0",
                restSeconds: 120,
                rpe: "6–7",
                targetMuscles: ["Quads", "Glutes", "Core"],
                commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                videoKeywords: "goblet squat form beginner",
                beginnerModification: "Reduce depth, bodyweight",
                advancedProgression: "Front-rack barbell, increase depth"
            ),
            ExerciseDef(
                id: "ex_sl_rdl",
                name: "Single-Leg Romanian Deadlift (DB)",
                kind: .strength,
                prescription: "3 × 8/side",
                tempo: "3-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                commonMistakes: ["Rotating hips", "Rounding back"],
                coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                videoKeywords: "single leg RDL tutorial",
                beginnerModification: "Hold wall/chair for balance",
                advancedProgression: "Increase load, slow eccentric only"
            ),
            ExerciseDef(
                id: "ex_step_up",
                name: "Step-Up (low box, knee height or below)",
                kind: .strength,
                prescription: "3 × 8/side",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Quads", "Glutes"],
                commonMistakes: ["Pushing off trailing leg", "Box too high"],
                coachingCues: ["Drive through the heel of the top leg"],
                videoKeywords: "step up exercise form",
                beginnerModification: "Lower box height",
                advancedProgression: "Add dumbbells, raise box"
            ),
            ExerciseDef(
                id: "ex_calf_raise_b",
                name: "Standing Calf Raise",
                kind: .strength,
                prescription: "3 × 12–15",
                tempo: "2-1-2-1",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Partial range"],
                coachingCues: ["Full stretch and squeeze"],
                videoKeywords: "standing calf raise form",
                beginnerModification: "Bodyweight",
                advancedProgression: "Add load"
            ),
            ExerciseDef(
                id: "ex_spanish_squat_b",
                name: "Spanish Squat Isometric Hold",
                kind: .isometric,
                prescription: "3 × 30–45s hold",
                tempo: "Isometric",
                restSeconds: 60,
                rpe: "6",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                videoKeywords: "Spanish squat tutorial",
                beginnerModification: "Reduce time or tension",
                advancedProgression: "Add load"
            ),
            ExerciseDef(
                id: "ex_bird_dog",
                name: "Bird Dog",
                kind: .strength,
                prescription: "2 × 10/side",
                tempo: "Controlled",
                restSeconds: 45,
                rpe: "6",
                targetMuscles: ["Core", "Glutes"],
                commonMistakes: ["Rushing", "Arching lower back"],
                coachingCues: ["Move slowly", "Keep hips level"],
                videoKeywords: "bird dog exercise form",
                beginnerModification: "Smaller range",
                advancedProgression: "Add pause at extension"
            )
        ],
        cooldown: "Quad/hip flexor stretch · gentle patellar tendon area foam roll · breathing"
    )

    static let upperB = WorkoutDef(
        type: .upperB,
        warmup: "Bike · band pull-aparts · arm circles",
        mobility: "Thoracic rotations · wrist mobility",
        activation: "Face pulls 2×15 · scap push-ups 2×10",
        exercises: [
            ExerciseDef(
                id: "ex_ohp",
                name: "Standing Barbell Overhead Press",
                kind: .strength,
                prescription: "3 × 8",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Shoulders", "Triceps", "Core"],
                commonMistakes: ["Overarching lower back", "Pressing forward"],
                coachingCues: ["Brace glutes/core", "Bar path straight up"],
                videoKeywords: "overhead press form",
                beginnerModification: "Seated or dumbbell version",
                advancedProgression: "Add pause at top"
            ),
            ExerciseDef(
                id: "ex_incline_press",
                name: "Incline DB Bench Press",
                kind: .strength,
                prescription: "3 × 8–10",
                tempo: "3-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Upper chest", "Shoulders"],
                commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                coachingCues: ["30–45° incline", "Control the descent"],
                videoKeywords: "incline dumbbell press form",
                beginnerModification: "Lighter load",
                advancedProgression: "Barbell incline"
            ),
            ExerciseDef(
                id: "ex_sa_row",
                name: "Single-Arm DB Row",
                kind: .strength,
                prescription: "3 × 10/side",
                tempo: "2-1-1-0",
                restSeconds: 90,
                rpe: "7",
                targetMuscles: ["Lats", "Mid-back"],
                commonMistakes: ["Rotating torso for momentum"],
                coachingCues: ["Row elbow to hip", "Keep torso square"],
                videoKeywords: "single arm dumbbell row",
                beginnerModification: "Reduce load",
                advancedProgression: "Add pause at top"
            ),
            ExerciseDef(
                id: "ex_lateral_raise",
                name: "DB Lateral Raise",
                kind: .strength,
                prescription: "3 × 12–15",
                tempo: "2-0-2-0",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Side delts"],
                commonMistakes: ["Using momentum", "Shrugging"],
                coachingCues: ["Lead with elbows", "Slight forward lean"],
                videoKeywords: "dumbbell lateral raise form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower eccentric"
            ),
            ExerciseDef(
                id: "ex_face_pull",
                name: "Face Pull (band or cable)",
                kind: .strength,
                prescription: "2 × 15",
                tempo: "2-1-2-0",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Rear delts", "Rotator cuff"],
                commonMistakes: ["Pulling too low", "Using arms only"],
                coachingCues: ["Pull to face height", "External rotate at the end"],
                videoKeywords: "face pull exercise form",
                beginnerModification: "Lighter band",
                advancedProgression: "Heavier band"
            ),
            ExerciseDef(
                id: "ex_hammer_curl",
                name: "Hammer Curl",
                kind: .strength,
                prescription: "2 × 12",
                tempo: "2-0-2-0",
                restSeconds: 60,
                rpe: "7",
                targetMuscles: ["Biceps", "Forearms"],
                commonMistakes: ["Swinging"],
                coachingCues: ["Elbows pinned"],
                videoKeywords: "hammer curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower tempo"
            ),
            ExerciseDef(
                id: "ex_knee_raise",
                name: "Hanging Knee Raise (or lying reverse crunch)",
                kind: .isometric,
                prescription: "2 × 10–12",
                tempo: "Controlled",
                restSeconds: 60,
                rpe: "6–7",
                targetMuscles: ["Lower abs"],
                commonMistakes: ["Swinging", "Using momentum"],
                coachingCues: ["Curl pelvis under", "Control the descent"],
                videoKeywords: "hanging knee raise form",
                beginnerModification: "Lying reverse crunch",
                advancedProgression: "Straight-leg raise"
            )
        ],
        cooldown: "Chest/shoulder stretch · upper back stretch · breathing"
    )

    static let phase1Workouts: [WorkoutDef] = [lowerA, upperA, lowerB, upperB]

    // MARK: - Phase 2 workouts (Hypertrophy 1, weeks 5–12)
    // Same warm-up/mobility/activation as Phase 1; higher volume + new accessory
    // slots per phase2_hypertrophy1_program.md. Carried-over exercises keep their
    // Phase 1 coaching content — only prescription/tempo/rest/RPE change.

    static let phase2LowerA = WorkoutDef(
        type: .lowerA,
        warmup: lowerA.warmup, mobility: lowerA.mobility, activation: lowerA.activation,
        exercises: [
            ExerciseDef(id: "ex_rdl_barbell", name: "Barbell Romanian Deadlift", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                videoKeywords: "Romanian deadlift form tutorial",
                beginnerModification: "Use dumbbells, reduce range of motion",
                advancedProgression: "Deficit RDL, heavier barbell load"),
            ExerciseDef(id: "ex_box_squat", name: "Box Squat (gated depth — see gate check)", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Adductors"],
                commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                videoKeywords: "box squat tutorial beginner",
                beginnerModification: "Reduce depth further, bodyweight only",
                advancedProgression: "Do not increase depth until the gate check is met; then increase depth gradually, add load"),
            ExerciseDef(id: "ex_hip_thrust", name: "Barbell Hip Thrust", kind: .strength,
                prescription: "3 × 10–12", tempo: "2-1-2-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Glutes", "Hamstrings"],
                commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                videoKeywords: "barbell hip thrust form",
                beginnerModification: "Bodyweight or single-leg glute bridge",
                advancedProgression: "Add pause at top, increase load"),
            ExerciseDef(id: "ex_bulgarian_split_squat", name: "Bulgarian Split Squat (rear foot elevated, shallow depth)", kind: .strength,
                prescription: "3 × 10/leg", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Hip stabilizers"],
                commonMistakes: ["Front knee traveling too far past toes", "Torso collapsing forward", "Rear foot elevated too high increasing knee flexion demand"],
                coachingCues: ["Most of your weight through the front heel", "Keep torso tall", "Start with a low bench/step (6–8\") for the rear foot, not a full bench"],
                videoKeywords: "Bulgarian split squat form beginner low knee stress",
                beginnerModification: "No rear elevation at all (reverse lunge instead), shallower depth",
                advancedProgression: "Add dumbbells, increase depth as tolerated, raise rear foot height"),
            ExerciseDef(id: "ex_spanish_squat", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 40s hold", tempo: "Isometric", restSeconds: 60, rpe: "6",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                videoKeywords: "Spanish squat patellar tendon",
                beginnerModification: "Reduce hold time or band tension",
                advancedProgression: "Add light dumbbell hold across chest"),
            ExerciseDef(id: "ex_calf_raise_a", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Bouncing", "Partial range"],
                coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                videoKeywords: "standing calf raise proper form",
                beginnerModification: "Bodyweight only",
                advancedProgression: "Add barbell load"),
            ExerciseDef(id: "ex_pallof", name: "Pallof Press", kind: .strength,
                prescription: "2 × 12/side", tempo: "Controlled", restSeconds: 45, rpe: "6",
                targetMuscles: ["Core (anti-rotation)"],
                commonMistakes: ["Letting hips rotate"],
                coachingCues: ["Brace your core", "Resist the band pulling you"],
                videoKeywords: "Pallof press tutorial",
                beginnerModification: "Lighter band",
                advancedProgression: "Half-kneeling variation")
        ],
        cooldown: lowerA.cooldown
    )

    static let phase2UpperA = WorkoutDef(
        type: .upperA,
        warmup: upperA.warmup, mobility: upperA.mobility, activation: upperA.activation,
        exercises: [
            ExerciseDef(id: "ex_bench", name: "Barbell Bench Press", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Chest", "Triceps", "Front delts"],
                commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                videoKeywords: "barbell bench press form",
                beginnerModification: "Dumbbell floor press",
                advancedProgression: "Add pause at chest"),
            ExerciseDef(id: "ex_cs_row", name: "Chest-Supported DB Row", kind: .strength,
                prescription: "4 × 10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Mid-back", "Biceps"],
                commonMistakes: ["Using momentum", "Shrugging shoulders"],
                coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                videoKeywords: "chest supported dumbbell row",
                beginnerModification: "Reduce load, seated band row",
                advancedProgression: "Single-arm variation"),
            ExerciseDef(id: "ex_seated_press", name: "Seated DB Shoulder Press", kind: .strength,
                prescription: "3 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps"],
                commonMistakes: ["Excessive lower back arch"],
                coachingCues: ["Brace core", "Press straight overhead"],
                videoKeywords: "seated dumbbell shoulder press",
                beginnerModification: "Reduce load, use seated back support",
                advancedProgression: "Standing variation"),
            ExerciseDef(id: "ex_pulldown", name: "Assisted Pull-up / Lat Pulldown", kind: .strength,
                prescription: "3 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Biceps"],
                commonMistakes: ["Using momentum", "Partial range"],
                coachingCues: ["Lead with the chest", "Full stretch at the top"],
                videoKeywords: "assisted pull up progression",
                beginnerModification: "Band-assisted",
                advancedProgression: "Add weight, reduce assistance"),
            ExerciseDef(id: "ex_db_flye", name: "Flat or Incline DB Flye", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Chest (isolation)"],
                commonMistakes: ["Bending elbows too much (turns it into a press)", "Going too heavy and losing control at the bottom"],
                coachingCues: ["Slight bend in elbows held constant throughout", "Think \u{201c}hugging a big tree,\u{201d} not pressing"],
                videoKeywords: "dumbbell flye proper form chest",
                beginnerModification: "Reduce range of motion, lighter weight",
                advancedProgression: "Incline variation, slower eccentric (4-second lowering)"),
            ExerciseDef(id: "ex_curl_a", name: "DB Bicep Curl", kind: .strength,
                prescription: "3 × 12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps"],
                commonMistakes: ["Swinging body", "Elbows drifting forward"],
                coachingCues: ["Elbows pinned to sides"],
                videoKeywords: "dumbbell bicep curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Alternate curl, slower eccentric"),
            ExerciseDef(id: "ex_pushdown", name: "Band/Cable Triceps Pushdown", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Triceps"],
                commonMistakes: ["Flaring elbows out"],
                coachingCues: ["Elbows locked at sides"],
                videoKeywords: "triceps pushdown form",
                beginnerModification: "Overhead DB extension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_plank", name: "Plank", kind: .isometric,
                prescription: "3 × 40–60s", tempo: "Isometric", restSeconds: 45, rpe: "6–7",
                targetMuscles: ["Core"],
                commonMistakes: ["Hips sagging or piking"],
                coachingCues: ["Straight line head to heel"],
                videoKeywords: "plank proper form",
                beginnerModification: "Knee plank",
                advancedProgression: "Add weight on back")
        ],
        cooldown: upperA.cooldown
    )

    static let phase2LowerB = WorkoutDef(
        type: .lowerB,
        warmup: lowerB.warmup, mobility: lowerB.mobility, activation: lowerB.activation,
        exercises: [
            ExerciseDef(id: "ex_goblet_squat", name: "Front or Goblet Squat (gated depth)", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Core"],
                commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                videoKeywords: "goblet squat form beginner",
                beginnerModification: "Reduce depth, bodyweight",
                advancedProgression: "Do not increase depth until the gate check is met; then front-rack barbell, increase depth"),
            ExerciseDef(id: "ex_sl_rdl", name: "Single-Leg Romanian Deadlift (DB)", kind: .strength,
                prescription: "3 × 8–10/side", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                commonMistakes: ["Rotating hips", "Rounding back"],
                coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                videoKeywords: "single leg RDL tutorial",
                beginnerModification: "Hold wall/chair for balance",
                advancedProgression: "Increase load, slow eccentric only"),
            ExerciseDef(id: "ex_step_up", name: "Step-Up (low box, knee height or below)", kind: .strength,
                prescription: "3 × 10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Quads", "Glutes"],
                commonMistakes: ["Pushing off trailing leg", "Box too high"],
                coachingCues: ["Drive through the heel of the top leg"],
                videoKeywords: "step up exercise form",
                beginnerModification: "Lower box height",
                advancedProgression: "Slightly increase box height only if gate check is met; add dumbbells"),
            ExerciseDef(id: "ex_leg_curl_band", name: "Band or Stability-Ball Leg Curl", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                targetMuscles: ["Hamstrings"],
                commonMistakes: ["Hips sagging or lifting too high", "Rushing the rep"],
                coachingCues: ["Keep hips elevated and level throughout", "Curl heels toward glutes under control"],
                videoKeywords: "stability ball hamstring curl form",
                beginnerModification: "Reduce range of motion, fewer reps",
                advancedProgression: "Single-leg variation, add ankle weight"),
            ExerciseDef(id: "ex_calf_raise_b", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Partial range"],
                coachingCues: ["Full stretch and squeeze"],
                videoKeywords: "standing calf raise form",
                beginnerModification: "Bodyweight",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_spanish_squat_b", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 40s hold", tempo: "Isometric", restSeconds: 60, rpe: "6",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                videoKeywords: "Spanish squat tutorial",
                beginnerModification: "Reduce time or tension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_bird_dog", name: "Bird Dog", kind: .strength,
                prescription: "2 × 10/side", tempo: "Controlled", restSeconds: 45, rpe: "6",
                targetMuscles: ["Core", "Glutes"],
                commonMistakes: ["Rushing", "Arching lower back"],
                coachingCues: ["Move slowly", "Keep hips level"],
                videoKeywords: "bird dog exercise form",
                beginnerModification: "Smaller range",
                advancedProgression: "Add pause at extension")
        ],
        cooldown: lowerB.cooldown
    )

    static let phase2UpperB = WorkoutDef(
        type: .upperB,
        warmup: upperB.warmup, mobility: upperB.mobility, activation: upperB.activation,
        exercises: [
            ExerciseDef(id: "ex_ohp", name: "Standing Barbell Overhead Press", kind: .strength,
                prescription: "4 × 8", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps", "Core"],
                commonMistakes: ["Overarching lower back", "Pressing forward"],
                coachingCues: ["Brace glutes/core", "Bar path straight up"],
                videoKeywords: "overhead press form",
                beginnerModification: "Seated or dumbbell version",
                advancedProgression: "Add pause at top"),
            ExerciseDef(id: "ex_incline_press", name: "Incline DB Bench Press", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Upper chest", "Shoulders"],
                commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                coachingCues: ["30–45° incline", "Control the descent"],
                videoKeywords: "incline dumbbell press form",
                beginnerModification: "Lighter load",
                advancedProgression: "Barbell incline"),
            ExerciseDef(id: "ex_sa_row", name: "Single-Arm DB Row", kind: .strength,
                prescription: "3 × 10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Mid-back"],
                commonMistakes: ["Rotating torso for momentum"],
                coachingCues: ["Row elbow to hip", "Keep torso square"],
                videoKeywords: "single arm dumbbell row",
                beginnerModification: "Reduce load",
                advancedProgression: "Add pause at top"),
            ExerciseDef(id: "ex_wide_grip_pulldown", name: "Wide-Grip Pulldown or Pull-up variation", kind: .strength,
                prescription: "3 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats (width emphasis)", "Biceps"],
                commonMistakes: ["Grip too wide (limits range and stresses shoulders)", "Leaning back excessively"],
                coachingCues: ["Grip just outside shoulder width", "Pull elbows down and back, chest up"],
                videoKeywords: "wide grip lat pulldown form",
                beginnerModification: "Band-assisted, closer grip",
                advancedProgression: "Weighted pull-up, slower eccentric"),
            ExerciseDef(id: "ex_lateral_raise", name: "DB Lateral Raise", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Side delts"],
                commonMistakes: ["Using momentum", "Shrugging"],
                coachingCues: ["Lead with elbows", "Slight forward lean"],
                videoKeywords: "dumbbell lateral raise form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower eccentric"),
            ExerciseDef(id: "ex_face_pull", name: "Face Pull (band or cable)", kind: .strength,
                prescription: "3 × 15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Rear delts", "Rotator cuff"],
                commonMistakes: ["Pulling too low", "Using arms only"],
                coachingCues: ["Pull to face height", "External rotate at the end"],
                videoKeywords: "face pull exercise form",
                beginnerModification: "Lighter band",
                advancedProgression: "Heavier band"),
            ExerciseDef(id: "ex_hammer_curl", name: "Hammer Curl", kind: .strength,
                prescription: "3 × 12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps", "Forearms"],
                commonMistakes: ["Swinging"],
                coachingCues: ["Elbows pinned"],
                videoKeywords: "hammer curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower tempo"),
            ExerciseDef(id: "ex_knee_raise", name: "Hanging Knee Raise (or lying reverse crunch)", kind: .isometric,
                prescription: "3 × 10–12", tempo: "Controlled", restSeconds: 60, rpe: "7",
                targetMuscles: ["Lower abs"],
                commonMistakes: ["Swinging", "Using momentum"],
                coachingCues: ["Curl pelvis under", "Control the descent"],
                videoKeywords: "hanging knee raise form",
                beginnerModification: "Lying reverse crunch",
                advancedProgression: "Straight-leg raise")
        ],
        cooldown: upperB.cooldown
    )

    static let phase2Workouts: [WorkoutDef] = [phase2LowerA, phase2UpperA, phase2LowerB, phase2UpperB]

    // MARK: - Phase 3 workouts (Strength Foundation, weeks 13–20)
    // No new exercises — shifts to lower reps/heavier loads on main lifts per
    // phase3_strength_foundation_program.md. Coaching content carried from Phase 1/2.

    static let phase3LowerA = WorkoutDef(
        type: .lowerA,
        warmup: lowerA.warmup, mobility: lowerA.mobility, activation: lowerA.activation,
        exercises: [
            ExerciseDef(id: "ex_rdl_barbell", name: "Barbell Romanian Deadlift", kind: .strength,
                prescription: "4 × 6–8", tempo: "3-1-1-0", restSeconds: 120, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                videoKeywords: "Romanian deadlift form tutorial",
                beginnerModification: "Use dumbbells, reduce range of motion",
                advancedProgression: "Deficit RDL, heavier barbell load"),
            ExerciseDef(id: "ex_box_squat", name: "Box Squat (depth per gate check)", kind: .strength,
                prescription: "4 × 5–6", tempo: "3-1-1-0", restSeconds: 150, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Adductors"],
                commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                videoKeywords: "box squat tutorial beginner",
                beginnerModification: "Reduce depth further, bodyweight only",
                advancedProgression: "Heaviest main-lift progression this phase — increase depth gradually as cleared, add load"),
            ExerciseDef(id: "ex_hip_thrust", name: "Barbell Hip Thrust", kind: .strength,
                prescription: "3 × 8–10", tempo: "2-1-2-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Glutes", "Hamstrings"],
                commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                videoKeywords: "barbell hip thrust form",
                beginnerModification: "Bodyweight or single-leg glute bridge",
                advancedProgression: "Add pause at top, increase load"),
            ExerciseDef(id: "ex_bulgarian_split_squat", name: "Bulgarian Split Squat (rear foot elevated, shallow depth)", kind: .strength,
                prescription: "3 × 8/leg", tempo: "2-1-2-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Hip stabilizers"],
                commonMistakes: ["Front knee traveling too far past toes", "Torso collapsing forward"],
                coachingCues: ["Most of your weight through the front heel", "Keep torso tall"],
                videoKeywords: "Bulgarian split squat form beginner low knee stress",
                beginnerModification: "No rear elevation at all (reverse lunge instead), shallower depth",
                advancedProgression: "Add dumbbells, increase depth as tolerated, raise rear foot height"),
            ExerciseDef(id: "ex_spanish_squat", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                videoKeywords: "Spanish squat patellar tendon",
                beginnerModification: "Reduce hold time or band tension",
                advancedProgression: "Add light dumbbell hold across chest"),
            ExerciseDef(id: "ex_calf_raise_a", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 10–12", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Bouncing", "Partial range"],
                coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                videoKeywords: "standing calf raise proper form",
                beginnerModification: "Bodyweight only",
                advancedProgression: "Add barbell load"),
            ExerciseDef(id: "ex_pallof", name: "Pallof Press", kind: .strength,
                prescription: "3 × 10/side", tempo: "Controlled", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core (anti-rotation)"],
                commonMistakes: ["Letting hips rotate"],
                coachingCues: ["Brace your core", "Resist the band pulling you"],
                videoKeywords: "Pallof press tutorial",
                beginnerModification: "Lighter band",
                advancedProgression: "Half-kneeling variation")
        ],
        cooldown: lowerA.cooldown
    )

    static let phase3UpperA = WorkoutDef(
        type: .upperA,
        warmup: upperA.warmup, mobility: upperA.mobility, activation: upperA.activation,
        exercises: [
            ExerciseDef(id: "ex_bench", name: "Barbell Bench Press", kind: .strength,
                prescription: "4 × 5–6", tempo: "3-1-1-0", restSeconds: 150, rpe: "7",
                targetMuscles: ["Chest", "Triceps", "Front delts"],
                commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                videoKeywords: "barbell bench press form",
                beginnerModification: "Dumbbell floor press",
                advancedProgression: "Main strength lift this phase — add pause at chest"),
            ExerciseDef(id: "ex_cs_row", name: "Chest-Supported DB Row", kind: .strength,
                prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Lats", "Mid-back", "Biceps"],
                commonMistakes: ["Using momentum", "Shrugging shoulders"],
                coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                videoKeywords: "chest supported dumbbell row",
                beginnerModification: "Reduce load, seated band row",
                advancedProgression: "Single-arm variation"),
            ExerciseDef(id: "ex_seated_press", name: "Seated DB Shoulder Press", kind: .strength,
                prescription: "3 × 6–8", tempo: "2-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps"],
                commonMistakes: ["Excessive lower back arch"],
                coachingCues: ["Brace core", "Press straight overhead"],
                videoKeywords: "seated dumbbell shoulder press",
                beginnerModification: "Reduce load, use seated back support",
                advancedProgression: "Standing variation"),
            ExerciseDef(id: "ex_pulldown", name: "Assisted Pull-up / Lat Pulldown", kind: .strength,
                prescription: "4 × 6–8", tempo: "2-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Lats", "Biceps"],
                commonMistakes: ["Using momentum", "Partial range"],
                coachingCues: ["Lead with the chest", "Full stretch at the top"],
                videoKeywords: "assisted pull up progression",
                beginnerModification: "Band-assisted",
                advancedProgression: "Add weight, reduce assistance"),
            ExerciseDef(id: "ex_db_flye", name: "Flat or Incline DB Flye", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Chest (isolation)"],
                commonMistakes: ["Bending elbows too much (turns it into a press)", "Going too heavy and losing control at the bottom"],
                coachingCues: ["Slight bend in elbows held constant throughout", "Think \u{201c}hugging a big tree,\u{201d} not pressing"],
                videoKeywords: "dumbbell flye proper form chest",
                beginnerModification: "Reduce range of motion, lighter weight",
                advancedProgression: "Accessory stays higher-rep — incline variation, slower eccentric"),
            ExerciseDef(id: "ex_curl_a", name: "DB Bicep Curl", kind: .strength,
                prescription: "3 × 10–12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps"],
                commonMistakes: ["Swinging body", "Elbows drifting forward"],
                coachingCues: ["Elbows pinned to sides"],
                videoKeywords: "dumbbell bicep curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Alternate curl, slower eccentric"),
            ExerciseDef(id: "ex_pushdown", name: "Band/Cable Triceps Pushdown", kind: .strength,
                prescription: "3 × 10–12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Triceps"],
                commonMistakes: ["Flaring elbows out"],
                coachingCues: ["Elbows locked at sides"],
                videoKeywords: "triceps pushdown form",
                beginnerModification: "Overhead DB extension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_plank", name: "Plank", kind: .isometric,
                prescription: "3 × 45–60s", tempo: "Isometric", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core"],
                commonMistakes: ["Hips sagging or piking"],
                coachingCues: ["Straight line head to heel"],
                videoKeywords: "plank proper form",
                beginnerModification: "Knee plank",
                advancedProgression: "Add light weight on back if comfortable")
        ],
        cooldown: upperA.cooldown
    )

    static let phase3LowerB = WorkoutDef(
        type: .lowerB,
        warmup: lowerB.warmup, mobility: lowerB.mobility, activation: lowerB.activation,
        exercises: [
            ExerciseDef(id: "ex_goblet_squat", name: "Front or Goblet Squat (depth per gate check)", kind: .strength,
                prescription: "4 × 6–8", tempo: "3-1-1-0", restSeconds: 150, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Core"],
                commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                videoKeywords: "goblet squat form beginner",
                beginnerModification: "Reduce depth, bodyweight",
                advancedProgression: "Front-rack barbell, increase depth as cleared"),
            ExerciseDef(id: "ex_sl_rdl", name: "Single-Leg Romanian Deadlift (DB)", kind: .strength,
                prescription: "3 × 6–8/side", tempo: "3-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                commonMistakes: ["Rotating hips", "Rounding back"],
                coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                videoKeywords: "single leg RDL tutorial",
                beginnerModification: "Hold wall/chair for balance",
                advancedProgression: "Increase load, slow eccentric only"),
            ExerciseDef(id: "ex_step_up", name: "Step-Up (low box, knee height or below)", kind: .strength,
                prescription: "3 × 8/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Quads", "Glutes"],
                commonMistakes: ["Pushing off trailing leg", "Box too high"],
                coachingCues: ["Drive through the heel of the top leg"],
                videoKeywords: "step up exercise form",
                beginnerModification: "Lower box height",
                advancedProgression: "Increase load (hold dumbbells) if not already"),
            ExerciseDef(id: "ex_leg_curl_band", name: "Band or Stability-Ball Leg Curl", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                targetMuscles: ["Hamstrings"],
                commonMistakes: ["Hips sagging or lifting too high", "Rushing the rep"],
                coachingCues: ["Keep hips elevated and level throughout", "Curl heels toward glutes under control"],
                videoKeywords: "stability ball hamstring curl form",
                beginnerModification: "Reduce range of motion, fewer reps",
                advancedProgression: "Single-leg variation, add ankle weight"),
            ExerciseDef(id: "ex_calf_raise_b", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 10–12", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Partial range"],
                coachingCues: ["Full stretch and squeeze"],
                videoKeywords: "standing calf raise form",
                beginnerModification: "Bodyweight",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_spanish_squat_b", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                videoKeywords: "Spanish squat tutorial",
                beginnerModification: "Reduce time or tension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_bird_dog", name: "Bird Dog", kind: .strength,
                prescription: "3 × 10/side", tempo: "Controlled", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core", "Glutes"],
                commonMistakes: ["Rushing", "Arching lower back"],
                coachingCues: ["Move slowly", "Keep hips level"],
                videoKeywords: "bird dog exercise form",
                beginnerModification: "Smaller range",
                advancedProgression: "Add pause at extension")
        ],
        cooldown: lowerB.cooldown
    )

    static let phase3UpperB = WorkoutDef(
        type: .upperB,
        warmup: upperB.warmup, mobility: upperB.mobility, activation: upperB.activation,
        exercises: [
            ExerciseDef(id: "ex_ohp", name: "Standing Barbell Overhead Press", kind: .strength,
                prescription: "4 × 5–6", tempo: "2-1-1-0", restSeconds: 150, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps", "Core"],
                commonMistakes: ["Overarching lower back", "Pressing forward"],
                coachingCues: ["Brace glutes/core", "Bar path straight up"],
                videoKeywords: "overhead press form",
                beginnerModification: "Seated or dumbbell version",
                advancedProgression: "Main strength lift this phase — add pause at top"),
            ExerciseDef(id: "ex_incline_press", name: "Incline DB Bench Press", kind: .strength,
                prescription: "4 × 6–8", tempo: "3-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Upper chest", "Shoulders"],
                commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                coachingCues: ["30–45° incline", "Control the descent"],
                videoKeywords: "incline dumbbell press form",
                beginnerModification: "Lighter load",
                advancedProgression: "Barbell incline"),
            ExerciseDef(id: "ex_sa_row", name: "Single-Arm DB Row", kind: .strength,
                prescription: "3 × 8/side", tempo: "2-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Lats", "Mid-back"],
                commonMistakes: ["Rotating torso for momentum"],
                coachingCues: ["Row elbow to hip", "Keep torso square"],
                videoKeywords: "single arm dumbbell row",
                beginnerModification: "Reduce load",
                advancedProgression: "Add pause at top"),
            ExerciseDef(id: "ex_wide_grip_pulldown", name: "Wide-Grip Pulldown or Pull-up variation", kind: .strength,
                prescription: "3 × 6–8", tempo: "2-1-1-0", restSeconds: 100, rpe: "7",
                targetMuscles: ["Lats (width emphasis)", "Biceps"],
                commonMistakes: ["Grip too wide (limits range and stresses shoulders)", "Leaning back excessively"],
                coachingCues: ["Grip just outside shoulder width", "Pull elbows down and back, chest up"],
                videoKeywords: "wide grip lat pulldown form",
                beginnerModification: "Band-assisted, closer grip",
                advancedProgression: "Weighted pull-up, slower eccentric, reduce assistance"),
            ExerciseDef(id: "ex_lateral_raise", name: "DB Lateral Raise", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Side delts"],
                commonMistakes: ["Using momentum", "Shrugging"],
                coachingCues: ["Lead with elbows", "Slight forward lean"],
                videoKeywords: "dumbbell lateral raise form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower eccentric"),
            ExerciseDef(id: "ex_face_pull", name: "Face Pull (band or cable)", kind: .strength,
                prescription: "3 × 15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Rear delts", "Rotator cuff"],
                commonMistakes: ["Pulling too low", "Using arms only"],
                coachingCues: ["Pull to face height", "External rotate at the end"],
                videoKeywords: "face pull exercise form",
                beginnerModification: "Lighter band",
                advancedProgression: "Heavier band"),
            ExerciseDef(id: "ex_hammer_curl", name: "Hammer Curl", kind: .strength,
                prescription: "3 × 10–12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps", "Forearms"],
                commonMistakes: ["Swinging"],
                coachingCues: ["Elbows pinned"],
                videoKeywords: "hammer curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower tempo"),
            ExerciseDef(id: "ex_knee_raise", name: "Hanging Knee Raise (or lying reverse crunch)", kind: .isometric,
                prescription: "3 × 10–12", tempo: "Controlled", restSeconds: 60, rpe: "7",
                targetMuscles: ["Lower abs"],
                commonMistakes: ["Swinging", "Using momentum"],
                coachingCues: ["Curl pelvis under", "Control the descent"],
                videoKeywords: "hanging knee raise form",
                beginnerModification: "Lying reverse crunch",
                advancedProgression: "Straight-leg raise")
        ],
        cooldown: upperB.cooldown
    )

    static let phase3Workouts: [WorkoutDef] = [phase3LowerA, phase3UpperA, phase3LowerB, phase3UpperB]

    // MARK: - Phase 4 workouts (Hypertrophy 2, weeks 21–32)
    // Highest-volume block: back to 8–15 reps at heavier loads, plus 4 new
    // exercises, per phase4_hypertrophy2_program.md.

    static let phase4LowerA = WorkoutDef(
        type: .lowerA,
        warmup: lowerA.warmup, mobility: lowerA.mobility, activation: lowerA.activation,
        exercises: [
            ExerciseDef(id: "ex_rdl_barbell", name: "Barbell Romanian Deadlift", kind: .strength,
                prescription: "4 × 10–12", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                videoKeywords: "Romanian deadlift form tutorial",
                beginnerModification: "Use dumbbells, reduce range of motion",
                advancedProgression: "Deficit RDL, heavier barbell load"),
            ExerciseDef(id: "ex_box_squat", name: "Box Squat (depth per gate check)", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Adductors"],
                commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                videoKeywords: "box squat tutorial beginner",
                beginnerModification: "Reduce depth further, bodyweight only",
                advancedProgression: "Same rep range as Phase 2, heavier load — increase depth gradually as cleared"),
            ExerciseDef(id: "ex_hip_thrust", name: "Barbell Hip Thrust", kind: .strength,
                prescription: "4 × 10–12", tempo: "2-1-2-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Glutes", "Hamstrings"],
                commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                videoKeywords: "barbell hip thrust form",
                beginnerModification: "Bodyweight or single-leg glute bridge",
                advancedProgression: "Add pause at top, increase load"),
            ExerciseDef(id: "ex_bulgarian_split_squat", name: "Bulgarian Split Squat (rear foot elevated, shallow depth)", kind: .strength,
                prescription: "3 × 10–12/leg", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Hip stabilizers"],
                commonMistakes: ["Front knee traveling too far past toes", "Torso collapsing forward"],
                coachingCues: ["Most of your weight through the front heel", "Keep torso tall"],
                videoKeywords: "Bulgarian split squat form beginner low knee stress",
                beginnerModification: "No rear elevation at all (reverse lunge instead), shallower depth",
                advancedProgression: "Add dumbbells, increase depth as tolerated, raise rear foot height"),
            ExerciseDef(id: "ex_pull_through", name: "Cable or Band Pull-Through", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Glutes", "Hamstrings (hip hinge, very low knee stress)"],
                commonMistakes: ["Squatting the movement instead of hinging", "Rounding the back"],
                coachingCues: ["Push hips back", "\u{201c}Hike\u{201d} the rope/band between your legs", "Drive hips forward to stand"],
                videoKeywords: "cable pull through exercise form",
                beginnerModification: "Lighter band tension, reduced range",
                advancedProgression: "Heavier band/cable stack, pause at hip extension"),
            ExerciseDef(id: "ex_spanish_squat", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                videoKeywords: "Spanish squat patellar tendon",
                beginnerModification: "Reduce hold time or band tension",
                advancedProgression: "Add light dumbbell hold across chest"),
            ExerciseDef(id: "ex_calf_raise_a", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Bouncing", "Partial range"],
                coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                videoKeywords: "standing calf raise proper form",
                beginnerModification: "Bodyweight only",
                advancedProgression: "Add barbell load"),
            ExerciseDef(id: "ex_pallof", name: "Pallof Press", kind: .strength,
                prescription: "3 × 12/side", tempo: "Controlled", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core (anti-rotation)"],
                commonMistakes: ["Letting hips rotate"],
                coachingCues: ["Brace your core", "Resist the band pulling you"],
                videoKeywords: "Pallof press tutorial",
                beginnerModification: "Lighter band",
                advancedProgression: "Half-kneeling variation")
        ],
        cooldown: lowerA.cooldown
    )

    static let phase4UpperA = WorkoutDef(
        type: .upperA,
        warmup: upperA.warmup, mobility: upperA.mobility, activation: upperA.activation,
        exercises: [
            ExerciseDef(id: "ex_bench", name: "Barbell Bench Press", kind: .strength,
                prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Chest", "Triceps", "Front delts"],
                commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                videoKeywords: "barbell bench press form",
                beginnerModification: "Dumbbell floor press",
                advancedProgression: "Add pause at chest"),
            ExerciseDef(id: "ex_cs_row", name: "Chest-Supported DB Row", kind: .strength,
                prescription: "4 × 10–12", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Mid-back", "Biceps"],
                commonMistakes: ["Using momentum", "Shrugging shoulders"],
                coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                videoKeywords: "chest supported dumbbell row",
                beginnerModification: "Reduce load, seated band row",
                advancedProgression: "Single-arm variation"),
            ExerciseDef(id: "ex_seated_press", name: "Seated DB Shoulder Press", kind: .strength,
                prescription: "4 × 10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps"],
                commonMistakes: ["Excessive lower back arch"],
                coachingCues: ["Brace core", "Press straight overhead"],
                videoKeywords: "seated dumbbell shoulder press",
                beginnerModification: "Reduce load, use seated back support",
                advancedProgression: "Standing variation"),
            ExerciseDef(id: "ex_pulldown", name: "Assisted Pull-up / Lat Pulldown", kind: .strength,
                prescription: "4 × 10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Biceps"],
                commonMistakes: ["Using momentum", "Partial range"],
                coachingCues: ["Lead with the chest", "Full stretch at the top"],
                videoKeywords: "assisted pull up progression",
                beginnerModification: "Band-assisted",
                advancedProgression: "Add weight, reduce assistance"),
            ExerciseDef(id: "ex_db_flye", name: "Flat or Incline DB Flye", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Chest (isolation)"],
                commonMistakes: ["Bending elbows too much (turns it into a press)", "Going too heavy and losing control at the bottom"],
                coachingCues: ["Slight bend in elbows held constant throughout", "Think \u{201c}hugging a big tree,\u{201d} not pressing"],
                videoKeywords: "dumbbell flye proper form chest",
                beginnerModification: "Reduce range of motion, lighter weight",
                advancedProgression: "Incline variation, slower eccentric (4-second lowering)"),
            ExerciseDef(id: "ex_single_arm_chest_press", name: "Single-Arm Cable or Band Chest Press", kind: .strength,
                prescription: "3 × 12/side", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Chest", "Core (anti-rotation)"],
                commonMistakes: ["Letting the torso rotate toward the working arm", "Pressing too fast"],
                coachingCues: ["Brace core hard", "Press straight forward", "Control the return"],
                videoKeywords: "single arm cable chest press form",
                beginnerModification: "Lighter band, seated version for more stability",
                advancedProgression: "Standing on one leg (added stability challenge), slower tempo"),
            ExerciseDef(id: "ex_curl_a", name: "DB Bicep Curl", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps"],
                commonMistakes: ["Swinging body", "Elbows drifting forward"],
                coachingCues: ["Elbows pinned to sides"],
                videoKeywords: "dumbbell bicep curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Alternate curl, slower eccentric"),
            ExerciseDef(id: "ex_pushdown", name: "Band/Cable Triceps Pushdown", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Triceps"],
                commonMistakes: ["Flaring elbows out"],
                coachingCues: ["Elbows locked at sides"],
                videoKeywords: "triceps pushdown form",
                beginnerModification: "Overhead DB extension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_plank", name: "Plank", kind: .isometric,
                prescription: "3 × 60s", tempo: "Isometric", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core"],
                commonMistakes: ["Hips sagging or piking"],
                coachingCues: ["Straight line head to heel"],
                videoKeywords: "plank proper form",
                beginnerModification: "Knee plank",
                advancedProgression: "Standard hold — add weight if easy")
        ],
        cooldown: upperA.cooldown
    )

    static let phase4LowerB = WorkoutDef(
        type: .lowerB,
        warmup: lowerB.warmup, mobility: lowerB.mobility, activation: lowerB.activation,
        exercises: [
            ExerciseDef(id: "ex_goblet_squat", name: "Front or Goblet Squat (depth per gate check)", kind: .strength,
                prescription: "4 × 10–12", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Core"],
                commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                videoKeywords: "goblet squat form beginner",
                beginnerModification: "Reduce depth, bodyweight",
                advancedProgression: "Front-rack barbell, increase depth as cleared"),
            ExerciseDef(id: "ex_sl_rdl", name: "Single-Leg Romanian Deadlift (DB)", kind: .strength,
                prescription: "3 × 10–12/side", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                commonMistakes: ["Rotating hips", "Rounding back"],
                coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                videoKeywords: "single leg RDL tutorial",
                beginnerModification: "Hold wall/chair for balance",
                advancedProgression: "Increase load, slow eccentric only"),
            ExerciseDef(id: "ex_step_up", name: "Step-Up (low box, knee height or below)", kind: .strength,
                prescription: "3 × 10–12/side", tempo: "2-1-1-0", restSeconds: 75, rpe: "7",
                targetMuscles: ["Quads", "Glutes"],
                commonMistakes: ["Pushing off trailing leg", "Box too high"],
                coachingCues: ["Drive through the heel of the top leg"],
                videoKeywords: "step up exercise form",
                beginnerModification: "Lower box height",
                advancedProgression: "Add dumbbells, raise box"),
            ExerciseDef(id: "ex_leg_curl_band", name: "Band or Stability-Ball Leg Curl", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Hamstrings"],
                commonMistakes: ["Hips sagging or lifting too high", "Rushing the rep"],
                coachingCues: ["Keep hips elevated and level throughout", "Curl heels toward glutes under control"],
                videoKeywords: "stability ball hamstring curl form",
                beginnerModification: "Reduce range of motion, fewer reps",
                advancedProgression: "Single-leg variation, add ankle weight"),
            ExerciseDef(id: "ex_walking_lunge", name: "Walking Lunge (shallow, short stride — gated)", kind: .strength,
                prescription: "3 × 10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Quads", "Glutes", "Balance/stability"],
                commonMistakes: ["Overly long stride", "Front knee traveling far past toes", "Torso leaning forward"],
                coachingCues: ["Shorter stride than feels natural at first", "Drop straight down, not forward", "Front shin close to vertical"],
                videoKeywords: "walking lunge proper form knee safe",
                beginnerModification: "Only introduce once cleared by a recent assessment (knee consistently clean) — until then substitute an extra Step-Up set instead. Once cleared: stationary reverse lunge, shorter range",
                advancedProgression: "Add dumbbells, increase stride length gradually"),
            ExerciseDef(id: "ex_calf_raise_b", name: "Standing Calf Raise", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                targetMuscles: ["Calves"],
                commonMistakes: ["Partial range"],
                coachingCues: ["Full stretch and squeeze"],
                videoKeywords: "standing calf raise form",
                beginnerModification: "Bodyweight",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_spanish_squat_b", name: "Spanish Squat Isometric Hold", kind: .isometric,
                prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                targetMuscles: ["Quads", "Patellar tendon"],
                commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                videoKeywords: "Spanish squat tutorial",
                beginnerModification: "Reduce time or tension",
                advancedProgression: "Add load"),
            ExerciseDef(id: "ex_bird_dog", name: "Bird Dog", kind: .strength,
                prescription: "3 × 10/side", tempo: "Controlled", restSeconds: 45, rpe: "7",
                targetMuscles: ["Core", "Glutes"],
                commonMistakes: ["Rushing", "Arching lower back"],
                coachingCues: ["Move slowly", "Keep hips level"],
                videoKeywords: "bird dog exercise form",
                beginnerModification: "Smaller range",
                advancedProgression: "Add pause at extension")
        ],
        cooldown: lowerB.cooldown
    )

    static let phase4UpperB = WorkoutDef(
        type: .upperB,
        warmup: upperB.warmup, mobility: upperB.mobility, activation: upperB.activation,
        exercises: [
            ExerciseDef(id: "ex_ohp", name: "Standing Barbell Overhead Press", kind: .strength,
                prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Shoulders", "Triceps", "Core"],
                commonMistakes: ["Overarching lower back", "Pressing forward"],
                coachingCues: ["Brace glutes/core", "Bar path straight up"],
                videoKeywords: "overhead press form",
                beginnerModification: "Seated or dumbbell version",
                advancedProgression: "Add pause at top"),
            ExerciseDef(id: "ex_incline_press", name: "Incline DB Bench Press", kind: .strength,
                prescription: "4 × 10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Upper chest", "Shoulders"],
                commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                coachingCues: ["30–45° incline", "Control the descent"],
                videoKeywords: "incline dumbbell press form",
                beginnerModification: "Lighter load",
                advancedProgression: "Barbell incline"),
            ExerciseDef(id: "ex_sa_row", name: "Single-Arm DB Row", kind: .strength,
                prescription: "4 × 10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats", "Mid-back"],
                commonMistakes: ["Rotating torso for momentum"],
                coachingCues: ["Row elbow to hip", "Keep torso square"],
                videoKeywords: "single arm dumbbell row",
                beginnerModification: "Reduce load",
                advancedProgression: "Add pause at top"),
            ExerciseDef(id: "ex_wide_grip_pulldown", name: "Wide-Grip Pulldown or Pull-up variation", kind: .strength,
                prescription: "4 × 10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                targetMuscles: ["Lats (width emphasis)", "Biceps"],
                commonMistakes: ["Grip too wide (limits range and stresses shoulders)", "Leaning back excessively"],
                coachingCues: ["Grip just outside shoulder width", "Pull elbows down and back, chest up"],
                videoKeywords: "wide grip lat pulldown form",
                beginnerModification: "Band-assisted, closer grip",
                advancedProgression: "Weighted pull-up, slower eccentric"),
            ExerciseDef(id: "ex_lateral_raise", name: "DB Lateral Raise", kind: .strength,
                prescription: "4 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Side delts"],
                commonMistakes: ["Using momentum", "Shrugging"],
                coachingCues: ["Lead with elbows", "Slight forward lean"],
                videoKeywords: "dumbbell lateral raise form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower eccentric"),
            ExerciseDef(id: "ex_face_pull", name: "Face Pull (band or cable)", kind: .strength,
                prescription: "3 × 15–20", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Rear delts", "Rotator cuff"],
                commonMistakes: ["Pulling too low", "Using arms only"],
                coachingCues: ["Pull to face height", "External rotate at the end"],
                videoKeywords: "face pull exercise form",
                beginnerModification: "Lighter band",
                advancedProgression: "Heavier band"),
            ExerciseDef(id: "ex_reverse_flye", name: "Reverse Pec Deck / Band Reverse Flye", kind: .strength,
                prescription: "3 × 15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Rear delts", "Upper back (shoulder health)"],
                commonMistakes: ["Using momentum", "Shrugging instead of squeezing shoulder blades"],
                coachingCues: ["Slight bend in elbows", "Lead with the pinky/back of hand", "Squeeze shoulder blades together at the top"],
                videoKeywords: "reverse flye rear delt form",
                beginnerModification: "Lighter band/dumbbells, seated version",
                advancedProgression: "Slower eccentric, pause at top"),
            ExerciseDef(id: "ex_hammer_curl", name: "Hammer Curl", kind: .strength,
                prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                targetMuscles: ["Biceps", "Forearms"],
                commonMistakes: ["Swinging"],
                coachingCues: ["Elbows pinned"],
                videoKeywords: "hammer curl form",
                beginnerModification: "Lighter load",
                advancedProgression: "Slower tempo"),
            ExerciseDef(id: "ex_knee_raise", name: "Hanging Knee Raise (or lying reverse crunch)", kind: .isometric,
                prescription: "3 × 12–15", tempo: "Controlled", restSeconds: 60, rpe: "7",
                targetMuscles: ["Lower abs"],
                commonMistakes: ["Swinging", "Using momentum"],
                coachingCues: ["Curl pelvis under", "Control the descent"],
                videoKeywords: "hanging knee raise form",
                beginnerModification: "Lying reverse crunch",
                advancedProgression: "Straight-leg raise")
        ],
        cooldown: upperB.cooldown
    )

    static let phase4Workouts: [WorkoutDef] = [phase4LowerA, phase4UpperA, phase4LowerB, phase4UpperB]

    // MARK: - Phase 5: Specialization (weeks 33–40, choose-your-track)
    // Per phase5_specialization_program.md: core Upper/Lower lifts continue at
    // 4×8-10 RPE7 (tempo/rest as Phase 4); the last 2 exercise slots become the
    // user's chosen track. Track B/C exercises append to both Lower sessions;
    // Track A exercises append to both Upper sessions (matching the doc, which
    // never asks Lower to grow when Track A is chosen, or vice versa).

    static let trackACloseGripBench = ExerciseDef(
        id: "ex_close_grip_bench", name: "Close-Grip Bench Press or DB Skull Crusher", kind: .strength,
        prescription: "3 × 10–12", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
        targetMuscles: ["Triceps"],
        commonMistakes: ["Elbows flaring out (defeats the purpose)"],
        coachingCues: ["Elbows tucked closer than standard bench", "~Shoulder-width grip"],
        videoKeywords: "close grip bench press form",
        beginnerModification: "Lighter load, reduce range of motion",
        advancedProgression: "Add pause at chest, slower eccentric")

    static let trackAInclineCurl = ExerciseDef(
        id: "ex_incline_curl", name: "Incline DB Curl", kind: .strength,
        prescription: "3 × 10–12", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
        targetMuscles: ["Biceps (full stretch emphasis)"],
        commonMistakes: ["Swinging, not using full range"],
        coachingCues: ["Let the arm hang fully behind the torso at the bottom for a full stretch"],
        videoKeywords: "incline dumbbell curl form",
        beginnerModification: "Lighter load",
        advancedProgression: "Slower eccentric")

    static let trackBGoodMorning = ExerciseDef(
        id: "ex_good_morning", name: "Barbell Good Morning (light, controlled)", kind: .strength,
        prescription: "3 × 10", tempo: "3-1-1-0", restSeconds: 90, rpe: "6–7",
        targetMuscles: ["Posterior chain (very low knee stress)"],
        commonMistakes: ["Rounding the back", "Using too much load too soon"],
        coachingCues: ["Soft knee bend held constant", "Hinge from the hips", "Keep the bar path close to the body"],
        videoKeywords: "barbell good morning form beginner",
        beginnerModification: "Very light load, reduced range",
        advancedProgression: "Increase load gradually, slower eccentric")

    static let trackBGluteKickback = ExerciseDef(
        id: "ex_glute_kickback", name: "Cable/Band Standing Glute Kickback", kind: .strength,
        prescription: "3 × 12–15/side", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
        targetMuscles: ["Glutes (isolation)"],
        commonMistakes: ["Using the lower back instead of hip extension for range"],
        coachingCues: ["Brace core", "Avoid arching the lower back to get range", "Squeeze glute at the top"],
        videoKeywords: "cable glute kickback form",
        beginnerModification: "Lighter band/cable, reduced range",
        advancedProgression: "Heavier resistance, pause at top")

    static let trackCLateralBandWalk = ExerciseDef(
        id: "ex_lateral_band_walk_loaded", name: "Lateral Band Walk (loaded, standalone)", kind: .strength,
        prescription: "3 × 10 steps/side", tempo: "Controlled", restSeconds: 60, rpe: "6–7",
        targetMuscles: ["Glute medius", "Frontal-plane strength for cutting/direction changes"],
        commonMistakes: ["Standing too upright (loses tension)", "Short, shuffling steps"],
        coachingCues: ["Athletic half-squat stance", "Keep tension on the band the whole set"],
        videoKeywords: "lateral band walk exercise form",
        beginnerModification: "Lighter band, smaller steps",
        advancedProgression: "Heavier band, longer steps")

    static let trackCDecelerationStep = ExerciseDef(
        id: "ex_deceleration_step", name: "Controlled Deceleration Step (landing mechanics drill)", kind: .strength,
        prescription: "3 × 6/side", tempo: "Controlled", restSeconds: 90, rpe: "6",
        targetMuscles: ["Quads", "Glutes", "Tendon/landing mechanics"],
        commonMistakes: ["Landing stiff-legged", "Knee caving inward on landing"],
        coachingCues: ["\u{201c}Land quiet,\u{201d} knee tracking over toes", "Absorb through a soft bend rather than stopping abruptly"],
        videoKeywords: "single leg landing mechanics drill low intensity",
        beginnerModification: "Step down from an even lower height (4–6\"), or land on both feet instead of one. Only proceed if the knee has been consistently clean per the gate check",
        advancedProgression: "Slightly higher step, add a small forward hop before the landing (only after weeks of clean landings)")

    /// The 2 track-specific exercises appended to Lower A/B for Track B or C
    /// (Track A adds nothing to Lower — its 2 slots live on Upper A/B instead).
    static func lowerTrackExercises(_ track: SpecializationTrack) -> [ExerciseDef] {
        switch track {
        case .armsShoulders: return []
        case .posteriorChain: return [trackBGoodMorning, trackBGluteKickback]
        case .athleticPerformance: return [trackCLateralBandWalk, trackCDecelerationStep]
        }
    }

    /// The 2 track-specific exercises appended to Upper A/B for Track A only.
    static func upperTrackExercises(_ track: SpecializationTrack) -> [ExerciseDef] {
        track == .armsShoulders ? [trackACloseGripBench, trackAInclineCurl] : []
    }

    static func phase5LowerA(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .lowerA,
            warmup: lowerA.warmup, mobility: lowerA.mobility, activation: lowerA.activation,
            exercises: [
                ExerciseDef(id: "ex_rdl_barbell", name: "Barbell Romanian Deadlift", kind: .strength,
                    prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                    commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                    coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                    videoKeywords: "Romanian deadlift form tutorial",
                    beginnerModification: "Use dumbbells, reduce range of motion",
                    advancedProgression: "Deficit RDL, heavier barbell load"),
                ExerciseDef(id: "ex_box_squat", name: "Box Squat (depth per gate check)", kind: .strength,
                    prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "7",
                    targetMuscles: ["Quads", "Glutes", "Adductors"],
                    commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                    coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                    videoKeywords: "box squat tutorial beginner",
                    beginnerModification: "Reduce depth further, bodyweight only",
                    advancedProgression: "Increase depth gradually as cleared, add load"),
                ExerciseDef(id: "ex_hip_thrust", name: "Barbell Hip Thrust", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-2-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Glutes", "Hamstrings"],
                    commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                    coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                    videoKeywords: "barbell hip thrust form",
                    beginnerModification: "Bodyweight or single-leg glute bridge",
                    advancedProgression: "Add pause at top, increase load"),
                ExerciseDef(id: "ex_bulgarian_split_squat", name: "Bulgarian Split Squat (rear foot elevated, shallow depth)", kind: .strength,
                    prescription: "3 × 10–12/leg", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                    targetMuscles: ["Quads", "Glutes", "Hip stabilizers"],
                    commonMistakes: ["Front knee traveling too far past toes", "Torso collapsing forward"],
                    coachingCues: ["Most of your weight through the front heel", "Keep torso tall"],
                    videoKeywords: "Bulgarian split squat form beginner low knee stress",
                    beginnerModification: "No rear elevation at all (reverse lunge instead), shallower depth",
                    advancedProgression: "Add dumbbells, increase depth as tolerated, raise rear foot height")
            ] + lowerTrackExercises(track) + [
                ExerciseDef(id: "ex_spanish_squat", name: "Spanish Squat Isometric Hold", kind: .isometric,
                    prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                    targetMuscles: ["Quads", "Patellar tendon"],
                    commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                    coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                    videoKeywords: "Spanish squat patellar tendon",
                    beginnerModification: "Reduce hold time or band tension",
                    advancedProgression: "Add light dumbbell hold across chest"),
                ExerciseDef(id: "ex_calf_raise_a", name: "Standing Calf Raise", kind: .strength,
                    prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Calves"],
                    commonMistakes: ["Bouncing", "Partial range"],
                    coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                    videoKeywords: "standing calf raise proper form",
                    beginnerModification: "Bodyweight only",
                    advancedProgression: "Add barbell load")
            ],
            cooldown: lowerA.cooldown
        )
    }

    static func phase5LowerB(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .lowerB,
            warmup: lowerB.warmup, mobility: lowerB.mobility, activation: lowerB.activation,
            exercises: [
                ExerciseDef(id: "ex_goblet_squat", name: "Front or Goblet Squat (depth per gate check)", kind: .strength,
                    prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Quads", "Glutes", "Core"],
                    commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                    coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                    videoKeywords: "goblet squat form beginner",
                    beginnerModification: "Reduce depth, bodyweight",
                    advancedProgression: "Front-rack barbell, increase depth as cleared"),
                ExerciseDef(id: "ex_sl_rdl", name: "Single-Leg Romanian Deadlift (DB)", kind: .strength,
                    prescription: "4 × 8–10/side", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                    commonMistakes: ["Rotating hips", "Rounding back"],
                    coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                    videoKeywords: "single leg RDL tutorial",
                    beginnerModification: "Hold wall/chair for balance",
                    advancedProgression: "Increase load, slow eccentric only"),
                ExerciseDef(id: "ex_step_up", name: "Step-Up (low box, knee height or below)", kind: .strength,
                    prescription: "3 × 10–12/side", tempo: "2-1-1-0", restSeconds: 75, rpe: "7",
                    targetMuscles: ["Quads", "Glutes"],
                    commonMistakes: ["Pushing off trailing leg", "Box too high"],
                    coachingCues: ["Drive through the heel of the top leg"],
                    videoKeywords: "step up exercise form",
                    beginnerModification: "Lower box height",
                    advancedProgression: "Add dumbbells, raise box"),
                ExerciseDef(id: "ex_leg_curl_band", name: "Band or Stability-Ball Leg Curl", kind: .strength,
                    prescription: "4 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Hamstrings"],
                    commonMistakes: ["Hips sagging or lifting too high", "Rushing the rep"],
                    coachingCues: ["Keep hips elevated and level throughout", "Curl heels toward glutes under control"],
                    videoKeywords: "stability ball hamstring curl form",
                    beginnerModification: "Reduce range of motion, fewer reps",
                    advancedProgression: "Single-leg variation, add ankle weight")
            ] + lowerTrackExercises(track) + [
                ExerciseDef(id: "ex_spanish_squat_b", name: "Spanish Squat Isometric Hold", kind: .isometric,
                    prescription: "3 × 45s hold", tempo: "Isometric", restSeconds: 60, rpe: "6–7",
                    targetMuscles: ["Quads", "Patellar tendon"],
                    commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                    coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                    videoKeywords: "Spanish squat tutorial",
                    beginnerModification: "Reduce time or tension",
                    advancedProgression: "Add load"),
                ExerciseDef(id: "ex_calf_raise_b", name: "Standing Calf Raise", kind: .strength,
                    prescription: "4 × 12–15", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Calves"],
                    commonMistakes: ["Partial range"],
                    coachingCues: ["Full stretch and squeeze"],
                    videoKeywords: "standing calf raise form",
                    beginnerModification: "Bodyweight",
                    advancedProgression: "Add load")
            ],
            cooldown: lowerB.cooldown
        )
    }

    static func phase5UpperA(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .upperA,
            warmup: upperA.warmup, mobility: upperA.mobility, activation: upperA.activation,
            exercises: [
                ExerciseDef(id: "ex_bench", name: "Barbell Bench Press", kind: .strength,
                    prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Chest", "Triceps", "Front delts"],
                    commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                    coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                    videoKeywords: "barbell bench press form",
                    beginnerModification: "Dumbbell floor press",
                    advancedProgression: "Add pause at chest"),
                ExerciseDef(id: "ex_cs_row", name: "Chest-Supported DB Row", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Mid-back", "Biceps"],
                    commonMistakes: ["Using momentum", "Shrugging shoulders"],
                    coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                    videoKeywords: "chest supported dumbbell row",
                    beginnerModification: "Reduce load, seated band row",
                    advancedProgression: "Single-arm variation"),
                ExerciseDef(id: "ex_seated_press", name: "Seated DB Shoulder Press", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Shoulders", "Triceps"],
                    commonMistakes: ["Excessive lower back arch"],
                    coachingCues: ["Brace core", "Press straight overhead"],
                    videoKeywords: "seated dumbbell shoulder press",
                    beginnerModification: "Reduce load, use seated back support",
                    advancedProgression: "Standing variation"),
                ExerciseDef(id: "ex_pulldown", name: "Assisted Pull-up / Lat Pulldown", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Biceps"],
                    commonMistakes: ["Using momentum", "Partial range"],
                    coachingCues: ["Lead with the chest", "Full stretch at the top"],
                    videoKeywords: "assisted pull up progression",
                    beginnerModification: "Band-assisted",
                    advancedProgression: "Add weight, reduce assistance")
            ] + (track == .armsShoulders ? upperTrackExercises(track) : [
                ExerciseDef(id: "ex_curl_a", name: "DB Bicep Curl", kind: .strength,
                    prescription: "3 × 12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Biceps"],
                    commonMistakes: ["Swinging body", "Elbows drifting forward"],
                    coachingCues: ["Elbows pinned to sides"],
                    videoKeywords: "dumbbell bicep curl form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Alternate curl, slower eccentric"),
                ExerciseDef(id: "ex_pushdown", name: "Band/Cable Triceps Pushdown", kind: .strength,
                    prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Triceps"],
                    commonMistakes: ["Flaring elbows out"],
                    coachingCues: ["Elbows locked at sides"],
                    videoKeywords: "triceps pushdown form",
                    beginnerModification: "Overhead DB extension",
                    advancedProgression: "Add load")
            ]) + [
                ExerciseDef(id: "ex_plank", name: "Plank", kind: .isometric,
                    prescription: "3 × 60s", tempo: "Isometric", restSeconds: 45, rpe: "7",
                    targetMuscles: ["Core"],
                    commonMistakes: ["Hips sagging or piking"],
                    coachingCues: ["Straight line head to heel"],
                    videoKeywords: "plank proper form",
                    beginnerModification: "Knee plank",
                    advancedProgression: "Add weight on back")
            ],
            cooldown: upperA.cooldown
        )
    }

    static func phase5UpperB(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .upperB,
            warmup: upperB.warmup, mobility: upperB.mobility, activation: upperB.activation,
            exercises: [
                ExerciseDef(id: "ex_ohp", name: "Standing Barbell Overhead Press", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Shoulders", "Triceps", "Core"],
                    commonMistakes: ["Overarching lower back", "Pressing forward"],
                    coachingCues: ["Brace glutes/core", "Bar path straight up"],
                    videoKeywords: "overhead press form",
                    beginnerModification: "Seated or dumbbell version",
                    advancedProgression: "Add pause at top"),
                ExerciseDef(id: "ex_incline_press", name: "Incline DB Bench Press", kind: .strength,
                    prescription: "4 × 8–10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Upper chest", "Shoulders"],
                    commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                    coachingCues: ["30–45° incline", "Control the descent"],
                    videoKeywords: "incline dumbbell press form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Barbell incline"),
                ExerciseDef(id: "ex_sa_row", name: "Single-Arm DB Row", kind: .strength,
                    prescription: "4 × 8–10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Mid-back"],
                    commonMistakes: ["Rotating torso for momentum"],
                    coachingCues: ["Row elbow to hip", "Keep torso square"],
                    videoKeywords: "single arm dumbbell row",
                    beginnerModification: "Reduce load",
                    advancedProgression: "Add pause at top"),
                ExerciseDef(id: "ex_wide_grip_pulldown", name: "Wide-Grip Pulldown or Pull-up variation", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats (width emphasis)", "Biceps"],
                    commonMistakes: ["Grip too wide (limits range and stresses shoulders)", "Leaning back excessively"],
                    coachingCues: ["Grip just outside shoulder width", "Pull elbows down and back, chest up"],
                    videoKeywords: "wide grip lat pulldown form",
                    beginnerModification: "Band-assisted, closer grip",
                    advancedProgression: "Weighted pull-up, slower eccentric")
            ] + (track == .armsShoulders ? upperTrackExercises(track) : [
                ExerciseDef(id: "ex_hammer_curl", name: "Hammer Curl", kind: .strength,
                    prescription: "3 × 12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Biceps", "Forearms"],
                    commonMistakes: ["Swinging"],
                    coachingCues: ["Elbows pinned"],
                    videoKeywords: "hammer curl form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Slower tempo"),
                ExerciseDef(id: "ex_face_pull", name: "Face Pull (band or cable)", kind: .strength,
                    prescription: "3 × 15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Rear delts", "Rotator cuff"],
                    commonMistakes: ["Pulling too low", "Using arms only"],
                    coachingCues: ["Pull to face height", "External rotate at the end"],
                    videoKeywords: "face pull exercise form",
                    beginnerModification: "Lighter band",
                    advancedProgression: "Heavier band")
            ]) + [
                ExerciseDef(id: "ex_knee_raise", name: "Hanging Knee Raise (or lying reverse crunch)", kind: .isometric,
                    prescription: "3 × 12–15", tempo: "Controlled", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Lower abs"],
                    commonMistakes: ["Swinging", "Using momentum"],
                    coachingCues: ["Curl pelvis under", "Control the descent"],
                    videoKeywords: "hanging knee raise form",
                    beginnerModification: "Lying reverse crunch",
                    advancedProgression: "Straight-leg raise")
            ],
            cooldown: upperB.cooldown
        )
    }

    // MARK: - Phase 6: Advanced Growth (weeks 41–48)
    // Introduces top-set + back-off structure on main lifts (prescription reads
    // as "Top set N, then M back-off × R"). Lower A/B always continue whichever
    // Phase 5 track was chosen; Upper A continues Track A only (per the doc,
    // Upper B has no track slot this phase). Weeks 49–52 (Phase 7 wind-down)
    // reuse these same definitions at reduced volume, per phase7's own notes.

    static func phase6LowerA(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .lowerA,
            warmup: lowerA.warmup, mobility: lowerA.mobility, activation: lowerA.activation,
            exercises: [
                ExerciseDef(id: "ex_rdl_barbell", name: "Barbell Romanian Deadlift", kind: .strength,
                    prescription: "Top set × 6, then 2 back-off × 8", tempo: "3-1-1-0", restSeconds: 120, rpe: "8 (top) · 6–7 (back-off)",
                    targetMuscles: ["Hamstrings", "Glutes", "Spinal erectors"],
                    commonMistakes: ["Rounding lower back", "Squatting the bar down instead of hinging"],
                    coachingCues: ["Push hips back like closing a car door with your butt", "Keep the bar close to your shins"],
                    videoKeywords: "Romanian deadlift form tutorial",
                    beginnerModification: "Use dumbbells, reduce range of motion",
                    advancedProgression: "1 top set at the heaviest, most focused effort; 2 back-off sets at ~85–90% of that weight"),
                ExerciseDef(id: "ex_box_squat", name: "Box Squat (full depth if cleared)", kind: .strength,
                    prescription: "Top set × 5, then 2 back-off × 6–8", tempo: "3-1-1-0", restSeconds: 150, rpe: "8 (top) · 6–7 (back-off)",
                    targetMuscles: ["Quads", "Glutes", "Adductors"],
                    commonMistakes: ["Squatting past pain-free depth", "Knees caving in"],
                    coachingCues: ["Sit back to the box under control", "Drive through mid-foot to stand", "Knees track over toes"],
                    videoKeywords: "box squat tutorial beginner",
                    beginnerModification: "Reduce depth further, bodyweight only",
                    advancedProgression: "Depth should be fully cleared by now if the knee has stayed clean"),
                ExerciseDef(id: "ex_hip_thrust", name: "Barbell Hip Thrust", kind: .strength,
                    prescription: "3 × 8–10", tempo: "2-1-2-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Glutes", "Hamstrings"],
                    commonMistakes: ["Overextending lower back at top", "Feet too far or too close"],
                    coachingCues: ["Squeeze glutes hard at lockout", "Keep ribs down"],
                    videoKeywords: "barbell hip thrust form",
                    beginnerModification: "Bodyweight or single-leg glute bridge",
                    advancedProgression: "Straight sets, unchanged structure"),
                ExerciseDef(id: "ex_bulgarian_split_squat", name: "Bulgarian Split Squat (rear foot elevated, shallow depth)", kind: .strength,
                    prescription: "3 × 10/leg", tempo: "2-1-2-0", restSeconds: 75, rpe: "7",
                    targetMuscles: ["Quads", "Glutes", "Hip stabilizers"],
                    commonMistakes: ["Front knee traveling too far past toes", "Torso collapsing forward"],
                    coachingCues: ["Most of your weight through the front heel", "Keep torso tall"],
                    videoKeywords: "Bulgarian split squat form beginner low knee stress",
                    beginnerModification: "No rear elevation at all (reverse lunge instead), shallower depth",
                    advancedProgression: "Unchanged from Phase 5")
            ] + lowerTrackExercises(track) + [
                ExerciseDef(id: "ex_spanish_squat", name: "Spanish Squat Isometric Hold", kind: .isometric,
                    prescription: "3 × 45–60s hold", tempo: "Isometric", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Quads", "Patellar tendon"],
                    commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                    coachingCues: ["Sit back into the band, shins vertical", "Breathe normally through the hold"],
                    videoKeywords: "Spanish squat patellar tendon",
                    beginnerModification: "Reduce hold time or band tension",
                    advancedProgression: "Slightly longer hold, still ongoing — this doesn't taper as loads increase"),
                ExerciseDef(id: "ex_calf_raise_a", name: "Standing Calf Raise", kind: .strength,
                    prescription: "4 × 10–12", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Calves"],
                    commonMistakes: ["Bouncing", "Partial range"],
                    coachingCues: ["Full stretch at the bottom", "Pause at the top"],
                    videoKeywords: "standing calf raise proper form",
                    beginnerModification: "Bodyweight only",
                    advancedProgression: "Unchanged")
            ],
            cooldown: lowerA.cooldown
        )
    }

    static func phase6LowerB(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .lowerB,
            warmup: lowerB.warmup, mobility: lowerB.mobility, activation: lowerB.activation,
            exercises: [
                ExerciseDef(id: "ex_goblet_squat", name: "Front or Goblet Squat (full depth if cleared)", kind: .strength,
                    prescription: "Top set × 6, then 2 back-off × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "8 (top) · 6–7 (back-off)",
                    targetMuscles: ["Quads", "Glutes", "Core"],
                    commonMistakes: ["Going below pain-free depth", "Elbows dropping"],
                    coachingCues: ["Elbows high", "Sit down not back", "Stop above any pinch"],
                    videoKeywords: "goblet squat form beginner",
                    beginnerModification: "Reduce depth, bodyweight",
                    advancedProgression: "1 top set at the heaviest, most focused effort; 2 back-off sets at ~85–90% of that weight"),
                ExerciseDef(id: "ex_sl_rdl", name: "Single-Leg Romanian Deadlift (DB)", kind: .strength,
                    prescription: "3 × 8–10/side", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Hamstrings", "Glutes", "Balance"],
                    commonMistakes: ["Rotating hips", "Rounding back"],
                    coachingCues: ["Hinge, keep hips square", "Light touch on floor"],
                    videoKeywords: "single leg RDL tutorial",
                    beginnerModification: "Hold wall/chair for balance",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_step_up", name: "Step-Up (or Walking Lunge if cleared)", kind: .strength,
                    prescription: "3 × 10/side", tempo: "2-1-1-0", restSeconds: 75, rpe: "7",
                    targetMuscles: ["Quads", "Glutes"],
                    commonMistakes: ["Pushing off trailing leg", "Box too high"],
                    coachingCues: ["Drive through the heel of the top leg"],
                    videoKeywords: "step up exercise form",
                    beginnerModification: "Lower box height",
                    advancedProgression: "Progress to Walking Lunge here if not already cleared/introduced in Phase 4"),
                ExerciseDef(id: "ex_leg_curl_band", name: "Band or Stability-Ball Leg Curl", kind: .strength,
                    prescription: "4 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Hamstrings"],
                    commonMistakes: ["Hips sagging or lifting too high", "Rushing the rep"],
                    coachingCues: ["Keep hips elevated and level throughout", "Curl heels toward glutes under control"],
                    videoKeywords: "stability ball hamstring curl form",
                    beginnerModification: "Reduce range of motion, fewer reps",
                    advancedProgression: "Unchanged")
            ] + lowerTrackExercises(track) + [
                ExerciseDef(id: "ex_calf_raise_b", name: "Standing Calf Raise", kind: .strength,
                    prescription: "4 × 10–12", tempo: "2-1-2-1", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Calves"],
                    commonMistakes: ["Partial range"],
                    coachingCues: ["Full stretch and squeeze"],
                    videoKeywords: "standing calf raise form",
                    beginnerModification: "Bodyweight",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_spanish_squat_b", name: "Spanish Squat Isometric Hold", kind: .isometric,
                    prescription: "3 × 45–60s hold", tempo: "Isometric", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Quads", "Patellar tendon"],
                    commonMistakes: ["Leaning too far back or forward", "Holding breath"],
                    coachingCues: ["Sit back into the band, shins vertical", "Breathe normally"],
                    videoKeywords: "Spanish squat tutorial",
                    beginnerModification: "Reduce time or tension",
                    advancedProgression: "Same as Lower A")
            ],
            cooldown: lowerB.cooldown
        )
    }

    static func phase6UpperA(track: SpecializationTrack) -> WorkoutDef {
        WorkoutDef(
            type: .upperA,
            warmup: upperA.warmup, mobility: upperA.mobility, activation: upperA.activation,
            exercises: [
                ExerciseDef(id: "ex_bench", name: "Barbell Bench Press", kind: .strength,
                    prescription: "Top set × 6, then 2 back-off × 8–10", tempo: "3-1-1-0", restSeconds: 120, rpe: "8 (top) · 6–7 (back-off)",
                    targetMuscles: ["Chest", "Triceps", "Front delts"],
                    commonMistakes: ["Flaring elbows too wide", "Bouncing bar off chest"],
                    coachingCues: ["Elbows ~45°", "Feet planted", "Control the descent"],
                    videoKeywords: "barbell bench press form",
                    beginnerModification: "Dumbbell floor press",
                    advancedProgression: "1 top set at the heaviest, most focused effort; 2 back-off sets at ~85–90% of that weight"),
                ExerciseDef(id: "ex_cs_row", name: "Chest-Supported DB Row", kind: .strength,
                    prescription: "4 × 10–12", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Mid-back", "Biceps"],
                    commonMistakes: ["Using momentum", "Shrugging shoulders"],
                    coachingCues: ["Pull elbows back", "Squeeze shoulder blades"],
                    videoKeywords: "chest supported dumbbell row",
                    beginnerModification: "Reduce load, seated band row",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_seated_press", name: "Seated DB Shoulder Press", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Shoulders", "Triceps"],
                    commonMistakes: ["Excessive lower back arch"],
                    coachingCues: ["Brace core", "Press straight overhead"],
                    videoKeywords: "seated dumbbell shoulder press",
                    beginnerModification: "Reduce load, use seated back support",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_pulldown", name: "Assisted Pull-up / Lat Pulldown", kind: .strength,
                    prescription: "4 × 8–10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Biceps"],
                    commonMistakes: ["Using momentum", "Partial range"],
                    coachingCues: ["Lead with the chest", "Full stretch at the top"],
                    videoKeywords: "assisted pull up progression",
                    beginnerModification: "Band-assisted",
                    advancedProgression: "Push toward less assistance or added weight if not already"),
                ExerciseDef(id: "ex_db_flye", name: "Flat or Incline DB Flye", kind: .strength,
                    prescription: "3 × 12–15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Chest (isolation)"],
                    commonMistakes: ["Bending elbows too much (turns it into a press)", "Going too heavy and losing control at the bottom"],
                    coachingCues: ["Slight bend in elbows held constant throughout", "Think \u{201c}hugging a big tree,\u{201d} not pressing"],
                    videoKeywords: "dumbbell flye proper form chest",
                    beginnerModification: "Reduce range of motion, lighter weight",
                    advancedProgression: "Unchanged")
            ] + (track == .armsShoulders ? upperTrackExercises(track) : [
                ExerciseDef(id: "ex_curl_a", name: "DB Bicep Curl", kind: .strength,
                    prescription: "3 × 12", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Biceps"],
                    commonMistakes: ["Swinging body", "Elbows drifting forward"],
                    coachingCues: ["Elbows pinned to sides"],
                    videoKeywords: "dumbbell bicep curl form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Standard accessory, unchanged"),
                ExerciseDef(id: "ex_pushdown", name: "Band/Cable Triceps Pushdown", kind: .strength,
                    prescription: "3 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Triceps"],
                    commonMistakes: ["Flaring elbows out"],
                    coachingCues: ["Elbows locked at sides"],
                    videoKeywords: "triceps pushdown form",
                    beginnerModification: "Overhead DB extension",
                    advancedProgression: "Standard accessory, unchanged")
            ]) + [
                ExerciseDef(id: "ex_plank", name: "Plank", kind: .isometric,
                    prescription: "3 × 60s+", tempo: "Isometric", restSeconds: 45, rpe: "7",
                    targetMuscles: ["Core"],
                    commonMistakes: ["Hips sagging or piking"],
                    coachingCues: ["Straight line head to heel"],
                    videoKeywords: "plank proper form",
                    beginnerModification: "Knee plank",
                    advancedProgression: "Add weight if bodyweight hold exceeds 60s comfortably")
            ],
            cooldown: upperA.cooldown
        )
    }

    /// Phase 6 Upper B has no specialization-track slot per the source program —
    /// it's the fixed 8-exercise list regardless of chosen track.
    static func phase6UpperB() -> WorkoutDef {
        WorkoutDef(
            type: .upperB,
            warmup: upperB.warmup, mobility: upperB.mobility, activation: upperB.activation,
            exercises: [
                ExerciseDef(id: "ex_ohp", name: "Standing Barbell Overhead Press", kind: .strength,
                    prescription: "Top set × 6, then 2 back-off × 8", tempo: "2-1-1-0", restSeconds: 120, rpe: "8 (top) · 6–7 (back-off)",
                    targetMuscles: ["Shoulders", "Triceps", "Core"],
                    commonMistakes: ["Overarching lower back", "Pressing forward"],
                    coachingCues: ["Brace glutes/core", "Bar path straight up"],
                    videoKeywords: "overhead press form",
                    beginnerModification: "Seated or dumbbell version",
                    advancedProgression: "1 top set at the heaviest, most focused effort; 2 back-off sets at ~85–90% of that weight"),
                ExerciseDef(id: "ex_incline_press", name: "Incline DB Bench Press", kind: .strength,
                    prescription: "4 × 10", tempo: "3-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Upper chest", "Shoulders"],
                    commonMistakes: ["Bench angle too steep", "Flaring elbows"],
                    coachingCues: ["30–45° incline", "Control the descent"],
                    videoKeywords: "incline dumbbell press form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_sa_row", name: "Single-Arm DB Row", kind: .strength,
                    prescription: "4 × 10/side", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats", "Mid-back"],
                    commonMistakes: ["Rotating torso for momentum"],
                    coachingCues: ["Row elbow to hip", "Keep torso square"],
                    videoKeywords: "single arm dumbbell row",
                    beginnerModification: "Reduce load",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_wide_grip_pulldown", name: "Wide-Grip Pulldown or Pull-up variation", kind: .strength,
                    prescription: "4 × 10", tempo: "2-1-1-0", restSeconds: 90, rpe: "7",
                    targetMuscles: ["Lats (width emphasis)", "Biceps"],
                    commonMistakes: ["Grip too wide (limits range and stresses shoulders)", "Leaning back excessively"],
                    coachingCues: ["Grip just outside shoulder width", "Pull elbows down and back, chest up"],
                    videoKeywords: "wide grip lat pulldown form",
                    beginnerModification: "Band-assisted, closer grip",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_lateral_raise", name: "DB Lateral Raise", kind: .strength,
                    prescription: "4 × 12–15", tempo: "2-0-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Side delts"],
                    commonMistakes: ["Using momentum", "Shrugging"],
                    coachingCues: ["Lead with elbows", "Slight forward lean"],
                    videoKeywords: "dumbbell lateral raise form",
                    beginnerModification: "Lighter load",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_face_pull", name: "Face Pull (band or cable)", kind: .strength,
                    prescription: "3 × 15–20", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Rear delts", "Rotator cuff"],
                    commonMistakes: ["Pulling too low", "Using arms only"],
                    coachingCues: ["Pull to face height", "External rotate at the end"],
                    videoKeywords: "face pull exercise form",
                    beginnerModification: "Lighter band",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_reverse_flye", name: "Reverse Pec Deck / Band Reverse Flye", kind: .strength,
                    prescription: "3 × 15", tempo: "2-1-2-0", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Rear delts", "Upper back (shoulder health)"],
                    commonMistakes: ["Using momentum", "Shrugging instead of squeezing shoulder blades"],
                    coachingCues: ["Slight bend in elbows", "Lead with the pinky/back of hand", "Squeeze shoulder blades together at the top"],
                    videoKeywords: "reverse flye rear delt form",
                    beginnerModification: "Lighter band/dumbbells, seated version",
                    advancedProgression: "Unchanged"),
                ExerciseDef(id: "ex_knee_raise", name: "Hanging Knee Raise (or lying reverse crunch)", kind: .isometric,
                    prescription: "3 × 12–15", tempo: "Controlled", restSeconds: 60, rpe: "7",
                    targetMuscles: ["Lower abs"],
                    commonMistakes: ["Swinging", "Using momentum"],
                    coachingCues: ["Curl pelvis under", "Control the descent"],
                    videoKeywords: "hanging knee raise form",
                    beginnerModification: "Lying reverse crunch",
                    advancedProgression: "Unchanged")
            ],
            cooldown: upperB.cooldown
        )
    }

    // MARK: - Phase-aware lookup

    private static func phase1Workout(_ type: WorkoutType) -> WorkoutDef {
        switch type {
        case .lowerA: return lowerA
        case .upperA: return upperA
        case .lowerB: return lowerB
        case .upperB: return upperB
        }
    }

    private static func phase2Workout(_ type: WorkoutType) -> WorkoutDef {
        switch type {
        case .lowerA: return phase2LowerA
        case .upperA: return phase2UpperA
        case .lowerB: return phase2LowerB
        case .upperB: return phase2UpperB
        }
    }

    private static func phase3Workout(_ type: WorkoutType) -> WorkoutDef {
        switch type {
        case .lowerA: return phase3LowerA
        case .upperA: return phase3UpperA
        case .lowerB: return phase3LowerB
        case .upperB: return phase3UpperB
        }
    }

    private static func phase4Workout(_ type: WorkoutType) -> WorkoutDef {
        switch type {
        case .lowerA: return phase4LowerA
        case .upperA: return phase4UpperA
        case .lowerB: return phase4LowerB
        case .upperB: return phase4UpperB
        }
    }

    private static func phase5Workout(_ type: WorkoutType, track: SpecializationTrack) -> WorkoutDef {
        switch type {
        case .lowerA: return phase5LowerA(track: track)
        case .upperA: return phase5UpperA(track: track)
        case .lowerB: return phase5LowerB(track: track)
        case .upperB: return phase5UpperB(track: track)
        }
    }

    private static func phase6Workout(_ type: WorkoutType, track: SpecializationTrack) -> WorkoutDef {
        switch type {
        case .lowerA: return phase6LowerA(track: track)
        case .upperA: return phase6UpperA(track: track)
        case .lowerB: return phase6LowerB(track: track)
        case .upperB: return phase6UpperB()
        }
    }

    /// Look up the workout definition for `type` at a given program `week`,
    /// applying the chosen Phase 5+ specialization `track` where relevant.
    /// Weeks 41–52 (Phase 6 + the Phase 7 wind-down) share the same content,
    /// since Phase 7 explicitly reuses Phase 6's workouts at reduced volume.
    static func workout(for type: WorkoutType, week: Int, track: SpecializationTrack = .armsShoulders) -> WorkoutDef {
        switch week {
        case ..<5: return phase1Workout(type)
        case 5..<13: return phase2Workout(type)
        case 13..<21: return phase3Workout(type)
        case 21..<33: return phase4Workout(type)
        case 33..<41: return phase5Workout(type, track: track)
        default: return phase6Workout(type, track: track)
        }
    }

    /// Back-compat overload for call sites without week/profile context.
    static func workout(for type: WorkoutType) -> WorkoutDef {
        workout(for: type, week: 1)
    }

    /// The weekly split template (day index 1–7 → session or rest note).
    static let weeklySchedule: [(day: Int, workout: WorkoutType?, note: String?)] = [
        (1, .lowerA, nil),
        (2, .upperA, nil),
        (3, nil, "Soccer or rest"),
        (4, .lowerB, nil),
        (5, .upperB, nil),
        (6, nil, "Soccer or rest"),
        (7, nil, "Soccer or rest")
    ]

    /// What's scheduled for a 1-based program day: either a workout or a rest note.
    static func scheduledWorkout(forProgramDay programDay: Int) -> (workout: WorkoutType?, note: String?) {
        let dayInWeek = ((max(1, programDay) - 1) % 7) + 1
        let entry = weeklySchedule.first { $0.day == dayInWeek } ?? weeklySchedule[0]
        return (entry.workout, entry.note)
    }
}
