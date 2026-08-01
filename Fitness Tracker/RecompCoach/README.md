# RecompCoach

Native SwiftUI iOS app for the 52-week body-recomposition coaching program (see
`../README_handoff.md` and `../Reference/`). This is the **Phase 1 MVP**: the core
logging, tracking, and dashboard loop running on-device.

## Status

**Built (v0.1 — Phase 1 MVP):**
- On-device SwiftData store (no CloudKit), auto-seeded profile on first launch
- **Today** — daily log (weight, calories, protein, carbs/fat/water, steps, mood,
  soreness, knee pain, notes), week-logging streak, nutrition targets
- **Workout** — log any of the 4 Phase 1 sessions (Lower A/B, Upper A/B) with
  per-exercise weight/reps/RPE (or hold/RPE for isometrics), expandable coaching
  cues, warm-up/mobility/activation, knee-during + next-morning tracking
- **Check-in** — weekly check-in with auto-fill (weight change, avg sleep, sessions)
  derived from logged data
- **History** — weight + knee-pain trend charts (Swift Charts), recent-entry feed,
  clear-all reset
- Header with live Week/Day count and the tendon-status meter
- Iron-gym design system ported from the HTML prototype

**Not yet built (roadmap, in the handoff spec):**
- Phases 2–7 program content (extend `ProgramCatalog.swift` the same way Phase 1 is modeled)
- HealthKit import/export (weight, steps, sleep, HRV; export workouts/nutrition)
- Notifications / motivation system, education lessons, meal plans, supplements
- Apple Watch companion (deferred out of v1 by decision)

## Requirements

- **Xcode 16 or newer** (this project uses file-system-synchronized groups).
  Not installed on the build machine yet — install from the App Store, then open
  `RecompCoach.xcodeproj`.
- iOS 17+ deployment target (required by SwiftData).

## Run it

1. `open RecompCoach.xcodeproj` in Xcode.
2. Select the **RecompCoach** scheme and an iPhone simulator (or your device).
3. For a physical device: set **Signing → Team** to your personal Apple ID
   (Automatic signing). The bundle id `com.parlov.RecompCoach` can be changed to
   anything unique.
4. Build & run (⌘R).

## Project layout

```
RecompCoach/
  RecompCoach.xcodeproj/
  RecompCoach/
    RecompCoachApp.swift        # @main, SwiftData container + profile seed
    Theme/Theme.swift           # palette, fonts, card/button styles
    Models/
      ProgramModels.swift       # program value types (immutable content)
      DataModels.swift          # SwiftData @Model user data
    Data/
      ProgramCatalog.swift      # Phase 1 workouts/exercises (authored content)
      ProgramClock.swift        # week/day math + tendon status
      Formatting.swift          # String<->optional-number helpers
    Views/
      RootView.swift            # header + tab shell
      TodayView.swift
      WorkoutLogView.swift
      CheckInView.swift
      HistoryView.swift
      Components.swift           # shared UI pieces
    Assets.xcassets
```

## Architecture notes

- **Program content is value types, not SwiftData.** `ProgramCatalog` ships the
  authored program as `struct`s. Only user-generated data (profile, daily logs,
  workout sessions, check-ins) is persisted via SwiftData. This keeps immutable
  content out of the user DB and avoids migrations when program content changes.
- Adding a phase = append a `PhaseDef` + its `WorkoutDef`s to `ProgramCatalog`.
