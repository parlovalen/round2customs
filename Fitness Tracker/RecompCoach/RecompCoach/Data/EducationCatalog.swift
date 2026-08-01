//
//  EducationCatalog.swift
//  RecompCoach
//
//  The full 12-month education curriculum (see education_curriculum.md) —
//  authored content, not user data. Written up front for the whole year
//  rather than gated month-by-month, per the user's choice.
//

import Foundation

struct EducationLesson: Identifiable, Hashable {
    let id: String
    let title: String
    let body: String
}

struct EducationMonth: Identifiable, Hashable {
    let month: Int
    let topic: String
    let lessons: [EducationLesson]

    var id: Int { month }
}

enum EducationCatalog {

    /// Maps a program week (1–52) onto a curriculum month (1–12).
    static func currentMonth(forWeek week: Int) -> Int {
        min(12, max(1, ((week - 1) * 12 / 52) + 1))
    }

    static func month(_ n: Int) -> EducationMonth? {
        months.first { $0.month == n }
    }

    static let months: [EducationMonth] = [

        EducationMonth(month: 1, topic: "Progressive overload · why recomp works · technique fundamentals", lessons: [
            EducationLesson(
                id: "m1_progressive_overload",
                title: "Progressive Overload, Explained Simply",
                body: "Muscles adapt to a demand that's slightly beyond what they're already handling. If you lift the same weight for the same reps forever, your body has no reason to change — it's already capable of that. Progressive overload just means giving your body a slightly bigger reason each week: a bit more weight, a bit more reps, or slightly better control of the same weight. That's why the progression rule in each phase is simple: if last session was clean (good form, hit the top of the rep range, didn't feel maxed out), add a small amount of load. If it wasn't clean, repeat it. There's no need to force progress every single session — the overall trend across weeks is what matters."
            ),
            EducationLesson(
                id: "m1_why_recomp_works",
                title: "Why Recomp Works Right Now (But Won't Forever)",
                body: "When your body is new to structured resistance training, your muscles are unusually responsive — even a modest calorie deficit doesn't blunt muscle growth the way it would in someone who's been training for years. Researchers sometimes call this the \"beginner gains\" window, and it typically lasts somewhere in the 6-12 month range. That's the entire reason this program is built around simultaneous fat loss and muscle gain instead of picking one first — it's taking advantage of a window that closes over time, not because recomp is always the \"best\" approach in general."
            ),
            EducationLesson(
                id: "m1_technique_basics",
                title: "The Few Things That Actually Matter for Technique",
                body: "It's tempting to think good lifting technique means memorizing dozens of cues. In reality, almost every exercise in this program comes down to a handful of the same principles: brace your core before you move, control the weight on the way down (don't just let gravity do it), and keep the working joint moving through a range you can control with good form, not just any range you can physically reach. The specific coaching cues in each workout are just that handful of principles applied to a specific movement."
            )
        ]),

        EducationMonth(month: 2, topic: "Protein & muscle protein synthesis · hydration basics", lessons: [
            EducationLesson(
                id: "m2_protein",
                title: "Protein: How Much, How Often, Why",
                body: "Muscle protein synthesis is the process your body uses to repair and build muscle tissue after training — protein is the raw material it needs. Your target of roughly 185g a day works out to about 1g per pound of bodyweight, comfortably in the range that maximizes muscle-building response without being excessive. Spreading it across 3–4 meals a day modestly improves how well your body uses it, since each meal can only drive so much synthesis at once — but total daily protein matters far more than perfect timing. Don't stress about a post-workout \"anabolic window\"; getting your day's protein in, reasonably distributed, is what actually moves the needle. A short day is fine to make up the next one."
            ),
            EducationLesson(
                id: "m2_hydration",
                title: "Hydration: The Boring Basics",
                body: "Even mild dehydration — as little as 2% of bodyweight in fluid loss — can measurably hurt strength and endurance, so hydration isn't just a wellness nicety. Your 3.75L daily target is a reasonable baseline for your size and training volume, more on hard-training or soccer days. Simple check: pale yellow urine means you're generally fine; consistently dark means catch up. Water is the default, but heavy sweating (soccer matches, hot days) means a bit of sodium — even just salting food normally — helps you retain the fluid instead of running straight through it. You don't need a specialized electrolyte product on typical days; save it for genuinely heavy-sweat days, per the supplement guide."
            )
        ]),

        EducationMonth(month: 3, topic: "Understanding RPE/RIR · why deload weeks matter", lessons: [
            EducationLesson(
                id: "m3_rpe_rir",
                title: "RPE and RIR, Explained",
                body: "RPE (Rate of Perceived Exertion) and RIR (Reps in Reserve) describe the same thing from opposite ends: how much you had left on a set. RPE 10 means you couldn't have done another rep; RPE 7 means you probably had about 3 more in you — RPE 7 ≈ 3 RIR. The program prescribes RPE, not a fixed percentage of your max, because your day-to-day capacity actually moves with sleep, stress, and soreness — a percentage-based plan doesn't know that, but RPE does. It takes a few weeks to calibrate honestly (most beginners underestimate how much they have left), but it sharpens with practice. When in doubt, guess conservative — undershooting costs little; overshooting regularly is how you end up fried or hurt."
            ),
            EducationLesson(
                id: "m3_deloads",
                title: "Why Deload Weeks Aren't a Break From Progress",
                body: "It's tempting to see a deload week as time off, or worse, time wasted. It's neither. Training creates a temporary dip in capacity — you're actually slightly weaker right after a hard block than before it, even as you adapt underneath. Deloads are where that gap closes: reduced load lets your body finish absorbing the last month's stimulus without piling more fatigue on top. Skip enough deloads and fatigue keeps compounding — quality drops, motivation drops, injury risk climbs, costing far more time than the deload would have. It's also why deload weeks line up with knee gate-checks: fatigue is when form breaks down and the tendon takes the hit. Treat the lighter week as seriously as the heavy ones."
            )
        ]),

        EducationMonth(month: 4, topic: "Sleep science & recovery basics", lessons: [
            EducationLesson(
                id: "m4_sleep",
                title: "Why Sleep Is the Highest-Leverage Recovery Tool You Have",
                body: "Most of the actual repair and adaptation from training happens while you sleep, not during the workout — the session creates the stimulus, sleep is where a meaningful chunk of the response happens (growth hormone release, muscle protein synthesis, nervous-system recovery). At a fixed 7 hours you're on the lower edge of the typically recommended 7–9, which is why consistency matters more for you than flexible hours might for someone else: the same wake time every day, weekends included, is the single highest-leverage lever available — more than bedtime itself. Morning light soon after waking helps anchor that rhythm further. None of this needs a perfect night; a few off nights inside an otherwise steady routine cost you very little."
            ),
            EducationLesson(
                id: "m4_recovery",
                title: "What \"Recovery\" Actually Means Day to Day",
                body: "Recovery isn't one thing — it's the sum of sleep, food, stress, and time between hard efforts. Soreness is a rough, unreliable signal (you can be sore and fully recovered, or not-sore and under-recovered), which is why resting heart rate, mood, and sleep get tracked alongside it — an elevated resting heart rate versus your personal baseline is often a better early flag than soreness alone. Two hard days close together (a heavy Lower session and a soccer match within 24 hours) is exactly when recovery basics stop being optional — that's the night sleep is non-negotiable. You don't need a perfect recovery score to keep training; the value is spotting the trend over weeks, not obsessing over any single day's number."
            )
        ]),

        EducationMonth(month: 5, topic: "Tendon health & load management (directly relevant to your knee)", lessons: [
            EducationLesson(
                id: "m5_tendon_biology",
                title: "Why Tendons Heal Slower Than Muscle (And What That Means for You)",
                body: "Muscle has a rich blood supply and turns over relatively quickly; tendons — including the patellar tendon behind your knee situation — have much less blood flow and remodel far more slowly. That mismatch is why tendon issues tend to develop quietly (muscle handles load increases faster than tendon can adapt) and why they take longer to resolve once irritated. It also means tendons respond well to a specific kind of load: slow, controlled, sustained tension — exactly what the daily isometric holds are for. This isn't a program that happens to include some knee exercises; the tendon protocol is a parallel track running underneath the whole year, which is why it doesn't pause for deloads or phase changes the way lifting does."
            ),
            EducationLesson(
                id: "m5_isometric_protocol",
                title: "The Point of the Daily Isometric Protocol",
                body: "Isometric holds — pushing against an immovable resistance without the joint moving — load tendon tissue in a way that's been shown to meaningfully reduce tendon pain, sometimes within days, likely by changing pain processing as well as gradually building tissue tolerance. That's why the protocol runs daily or near-daily regardless of the training schedule: consistency matters more here than intensity. The gate-check logic (knee pain ≤2/10, no next-morning soreness, for 2+ consecutive weeks before increasing squat depth or load) exists because tendon setbacks are almost always caused by ramping load faster than tissue can absorb — not by any single \"wrong\" exercise. If pain climbs mid-week, backing off for a few days costs far less than pushing through and resetting the clock."
            )
        ]),

        EducationMonth(month: 6, topic: "Energy balance & the 6-month recomp reassessment", lessons: [
            EducationLesson(
                id: "m6_energy_balance",
                title: "Energy Balance, Simplified",
                body: "Body recomposition — losing fat while gaining muscle at the same time — works because two separate systems are in play: fat loss is driven mainly by your average calorie balance over time, while muscle gain is driven mainly by training stimulus plus adequate protein. They don't have to fight each other the way \"bulk\" or \"cut\" framing implies. Day-to-day fluctuation is normal and mostly water/food weight, not fat or muscle changing that fast — what matters is the multi-week trend, which is why the weekly check-in tracks a rolling weight change instead of reacting to any single morning's number. It's also why the nutrition targets don't need surgical precision every day — being close on most days, most weeks, is what drives the outcome over a year."
            ),
            EducationLesson(
                id: "m6_reassessment",
                title: "Reading Your 6-Month Numbers Honestly",
                body: "This is the point in the plan built specifically to ask: is pure recomp still working, or has progress stalled enough that a short, deliberate lean-bulk or mini-cut block would serve you better for a while? Neither answer is a failure — recomp works best early in training and can naturally slow as your body adapts, a sign the approach did its job, not that something went wrong. Look at the trend across the full 6 months, not just the last few weeks: weight direction, strength on your main lifts at matched rep ranges, how clothes fit, and how the knee has held up under increasing load. If the numbers are genuinely ambiguous, that's normal too — a short, focused block in one direction for 4–8 weeks often clarifies things faster than more months of the same approach."
            )
        ]),

        EducationMonth(month: 7, topic: "How muscle actually grows (tension, metabolic stress, damage)", lessons: [
            EducationLesson(
                id: "m7_growth_drivers",
                title: "The Three Drivers of Muscle Growth",
                body: "Muscle growth is generally understood to come from three overlapping mechanisms: mechanical tension (the force the muscle produces against a load), metabolic stress (the \"burn\" and pump from higher-rep, shorter-rest work), and muscle damage (the microscopic tissue disruption that triggers repair). Mechanical tension is the biggest driver by most current understanding, which is exactly why the program is built around progressively adding load or reps on compound lifts rather than chasing the pump — the pump can feel productive without being the main thing driving growth. Rep ranges shift across phases (higher reps in the hypertrophy phases, lower in the strength phase) specifically to draw on a mix of these mechanisms across the year, rather than training the same rep range indefinitely."
            ),
            EducationLesson(
                id: "m7_soreness_myth",
                title: "Why More Soreness Doesn't Mean More Growth",
                body: "Muscle damage is one contributor to growth, which leads to the common but wrong idea that more soreness must mean a better session. In reality, soreness mostly reflects how unfamiliar a movement or rep range is to your body right now — it fades as you adapt to a given exercise even while you keep progressing on it, and a session with zero soreness can still be building real strength and size. Chasing soreness on purpose (random exercise variation, training through fatigue) mostly just adds recovery cost without proportional benefit, and can crowd out the progressive overload that's actually doing the work. Use soreness as one input on how recovery is trending, not a scorecard for whether a workout counted."
            )
        ]),

        EducationMonth(month: 8, topic: "Common beginner mistakes & plateau troubleshooting", lessons: [
            EducationLesson(
                id: "m8_beginner_mistakes",
                title: "The Most Common Beginner Mistakes (And Why They're Common)",
                body: "The biggest one is program-hopping — switching approaches every few weeks because progress feels slow, which resets the adaptation clock before any single approach gets a fair test. Close behind is chasing weight on the bar at the expense of form, trading long-term progress (and joint health, in your case especially) for a short-term number. A third is treating nutrition as all-or-nothing — one \"bad\" day doesn't undo a week of consistency, but the all-or-nothing mindset often turns one off day into a week of giving up entirely. The common thread: all three want faster feedback than a slow, biological process actually provides. This plan is built specifically to remove the decision-making that leads to these mistakes — it already tells you when to add load and when to deload. The job is just showing up and following it."
            ),
            EducationLesson(
                id: "m8_plateau_checklist",
                title: "A Plateau Isn't a Mystery, It's a Checklist",
                body: "When a lift stalls for a few sessions in a row, it's rarely random — it's almost always one of a small number of usual suspects: sleep that's slipped below target recently, a deload that got skipped or half-done, or rep quality that's quietly gotten sloppier without you noticing (partial reps, momentum, form breakdown at the top of the set). Work through those three before assuming you need a totally different program or exercise. A genuine long-term plateau (weeks, not days) more often means volume or intensity needs a real, planned change — which the phase structure already builds in — rather than something to fix with random extra work stacked on top. A flat few sessions is data, not a verdict."
            )
        ]),

        EducationMonth(month: 9, topic: "Specialization & individualization principles", lessons: [
            EducationLesson(
                id: "m9_specialization_timing",
                title: "Why Specialization Comes After a Base, Not Before",
                body: "By this point you have roughly 8 months of consistent training experience — enough to actually know what's lagging, rather than guessing based on what looks impressive. That's the entire logic behind waiting until Phase 5 to introduce a chosen focus area: specializing too early, before a base of general strength and movement competence exists, tends to just mean extra volume on a body that hasn't finished building its foundation. Now, two exercise slots per session can be reallocated toward whichever area your recent assessments actually show is lagging relative to the rest — arms/shoulders, posterior chain, or athletic carryover — rather than whatever you feel like working on that day. The core 4-day structure stays exactly the same; only a small, deliberate slice of it shifts."
            ),
            EducationLesson(
                id: "m9_individualization",
                title: "Individualization: Your Data Beats Generic Advice",
                body: "Generic training advice has to work reasonably well for a huge range of people, which means it's rarely optimal for any one person specifically — including you. Your own logged data (which lifts respond fastest to added load, how your knee actually responds to volume versus intensity, which rep ranges you recover from fastest) is a better guide for you specifically than any general rule, including some of the defaults in this program's own structure. That's the real point of a year of consistent logging: not just to look back at, but to start noticing your own patterns and adjusting around them — training is one of the few areas where \"it depends\" is usually the honest answer, and your own history is what fills in the blank."
            )
        ]),

        EducationMonth(month: 10, topic: "Injury prevention & athletic performance carryover (soccer-specific)", lessons: [
            EducationLesson(
                id: "m10_lifting_protection",
                title: "How Lifting Actually Protects You on the Field",
                body: "Strength training reduces injury risk in field sports mainly by increasing tissue capacity — tendons, ligaments, and muscle can absorb higher forces before something gives, which matters directly for a sport built on sudden accelerations, cuts, and landings. This is directly relevant to your knee too: a stronger, more resilient quad/hamstring/glute system around the joint reduces the load the tendon itself has to absorb during those sudden movements. This is exactly why soccer isn't treated as separate from the lifting program but as something the lifting is actively supporting — the two aren't competing demands, they're reinforcing each other, provided recovery keeps pace with both."
            ),
            EducationLesson(
                id: "m10_deceleration",
                title: "Deceleration Is a Skill, Not Just Strength",
                body: "Most non-contact injuries in field sports happen while decelerating or changing direction, not while sprinting in a straight line — which means the ability to control and absorb force (eccentric strength) matters as much as the ability to produce it. That's part of why Phase 5's athletic-performance track, if chosen, introduces controlled deceleration and single-leg stability work specifically, rather than more generic lower-body volume. It's also exactly why that track is gated on a clean knee history through Phase 4 — deceleration work asks more of the tendon under load than straight-line strength work does, so it's introduced once there's real evidence the joint can handle it, not on a fixed calendar date regardless of how things have gone."
            )
        ]),

        EducationMonth(month: 11, topic: "Advanced training concepts: autoregulation, top-set/back-off structures", lessons: [
            EducationLesson(
                id: "m11_autoregulation",
                title: "Autoregulation: Training to Today, Not to a Spreadsheet",
                body: "A rigid percentage-based program tells you what to lift based on a number from weeks ago; autoregulation — using RPE to guide the actual weight on the bar — adjusts to how you're recovering right now, which after 9+ months of training you're now well-practiced at reading honestly. A low-sleep, high-stress day might mean the same prescribed RPE lands on a lighter bar than last week, and that's the system working as intended, not a failure to progress. This is a more advanced skill than following a fixed percentage table, which is why it's been building all year rather than introduced on day one — by now your RPE estimates are calibrated enough to actually trust."
            ),
            EducationLesson(
                id: "m11_top_set_back_off",
                title: "Why Top-Set/Back-Off Beats Straight Sets at This Stage",
                body: "A top-set/back-off structure — one hard set at a real, near-limit effort, followed by a few lighter sets at reduced weight — lets you push genuine intensity on a single set without needing every set of the session at that same grinding effort, which would accumulate fatigue faster than it builds capability. The top set is where you actually test and push your ceiling; the back-off sets add volume at a more sustainable cost. This only makes sense to introduce once technique is solid enough to hold up under a true near-limit effort, which is why it waits until Phase 6 rather than appearing earlier — pushing RPE 8–9 on shaky technique is a good way to turn a training tool into an injury."
            )
        ]),

        EducationMonth(month: 12, topic: "Long-term periodization & thinking in years, not weeks", lessons: [
            EducationLesson(
                id: "m12_periodization",
                title: "Periodization Is Just Planned Variation",
                body: "Periodization sounds technical, but it's a simple idea: deliberately varying volume, intensity, and focus over time so you keep adapting instead of plateauing on the same stimulus indefinitely, while managing fatigue so it doesn't quietly accumulate past what deloads can absorb. The whole year you just finished was one long periodized plan — hypertrophy blocks, a strength block, specialization, advanced intensity techniques, and a wind-down — each phase building on what the last one established rather than repeating it. That structure is the actual reason a full year of progress was possible without a major injury or burnout derailing it partway through, not luck."
            ),
            EducationLesson(
                id: "m12_year_two",
                title: "This Year Was Never the Whole Plan",
                body: "The \"beginner gains\" window that made simultaneous fat loss and muscle gain realistic this year typically narrows somewhere in the 6–12 month range — which means Year 2 is where the plan has to become more deliberate: probably picking a clearer primary goal (leaning out further, or a dedicated muscle-building block) rather than running recomp indefinitely, since the easy dual-progress phase is closing. That's not a discouraging finding — it's exactly what the Week 51 assessment exists to catch, using a full year of your own data instead of a guess. Whatever you decide for Year 2, the habits underneath it (consistent logging, RPE-based autoregulation, tendon maintenance, sleep consistency) are now just how you train — they don't reset just because the specific program does."
            )
        ])
    ]
}
