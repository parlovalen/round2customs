# Motivation & Behavioral Support System

> Built as a rules + content-bank system so it can map directly into app notification logic later.

---

## Trigger Logic (for the app)

| Trigger Condition | Response Category |
|---|---|
| Workout logged | Brief acknowledgment + streak count |
| 2+ consecutive scheduled sessions missed | Encouragement (non-shaming) message |
| Same weight/reps/RPE logged for 3 consecutive sessions on a lift | Plateau guidance prompt |
| New top weight or rep count logged on a main lift | Milestone celebration |
| Deload week begins | Reframe message (deload = progress, not a break from progress) |
| Week 4/8/12... assessment day arrives | Assessment reminder + monthly summary |
| 7-day daily-log streak reached | Consistency milestone |
| Knee pain score ≥5 logged | Not a motivational message — a direct, calm flag to back off and consider the gate-check guidance |
| Phase transition (e.g., Week 5 begins) | New-phase orientation message |
| Program halfway point (Week 26) / full completion (Week 52) | Major milestone celebration |

---

## Sample Message Bank

**General encouragement (daily/session-based):**
- "Another one logged. This is the boring, unglamorous part that actually works."
- "Consistency compounds — today's session is one more brick, not the whole wall."
- "You don't have to feel motivated to show up. Showing up is what creates the motivation."

**Pre-workout:**
- "Same plan as always: warm up, work the lifts, don't chase a number that isn't there today."
- "If today's a lower-energy day, that's fine — RPE is relative to how you feel right now, not to last week."

**Post-hard-session:**
- "That one earned the rest of your day off from thinking about it."
- "Recovery starts now — food, water, and sleep tonight are doing real work."

**After a missed workout (non-shaming, redirect forward):**
- "One missed session doesn't undo the last few weeks. Next one's what matters — when's it happening?"
- "No need to make up for it by overdoing the next one. Just pick back up where the plan left off."

**Plateau guidance (triggered after 3 flat sessions on a lift):**
- "This lift's been flat for a few sessions — normal, not a sign anything's wrong. Check: sleep the last week, whether the last deload actually happened, and whether reps/form have been fully clean. Usually one of those three explains it."

**Milestone celebrations:**
- "New number on the board: [lift] at [weight] for [reps]. That's real progress, logged and real."
- "One month in. Look back at Week 1's numbers — that's not nothing."
- "Halfway through the year. Whatever the scale says today, you've shown up for 26 weeks — that's the actual achievement."

**Deload week framing:**
- "This week's lighter on purpose — deloads are where the last month's training actually gets absorbed, not wasted time."

**Consistency streak:**
- "7 days logged in a row. That's the habit becoming automatic."

---

## Weekly Summary Template (auto-generated from tracked data)
> "This week: [X] of 4 sessions completed · avg sleep [X]h · weight [↑/↓/→] [X] lb · knee pain trending [better/same/worse]. [One data-driven note, e.g., 'Bench press added 5lb this week' or 'Sleep dipped below target 3 nights — worth watching next week.']"

## Milestone Definitions (for app implementation)
- First month complete (Week 4)
- Any new logged PR (weight × reps combination not previously achieved on that lift)
- 25%, 50%, 75%, 100% program completion (Weeks 13, 26, 39, 52)
- Any 4-week streak of ≥90% workout adherence
- First time all 4 sessions completed in a single week (if that hasn't been consistent)
