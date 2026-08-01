//
//  FullProgramView.swift
//  RecompCoach
//
//  The full 52-week program at a glance: every phase as a chip with its week
//  range and goals, the current phase called out. Pushed from the Workout
//  tab's program card ("Full program").
//

import SwiftUI

struct FullProgramView: View {
    let currentWeek: Int

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(ProgramCatalog.phases) { phase in
                    PhaseChip(phase: phase, isCurrent: phase.contains(week: currentWeek))
                }
            }
            .padding(16)
            .padding(.bottom, 110)
        }
        .background(Theme.charcoal)
        .navigationTitle("Full Program")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Phase chip

private struct PhaseChip: View {
    let phase: PhaseDef
    let isCurrent: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 10) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(phase.name).displayHeading()
                        .foregroundStyle(Theme.chalk)
                    Text("Weeks \(phase.weekStart)–\(phase.weekEnd)")
                        .font(.system(size: 12.5))
                        .foregroundStyle(Theme.chalkDim)
                }
                Spacer(minLength: 8)
                if isCurrent {
                    Text("CURRENT")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(Color(hex: 0x151515))
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(Theme.ember)
                        .clipShape(Capsule())
                }
            }
            VStack(alignment: .leading, spacing: 8) {
                ForEach(phase.goals, id: \.self) { goal in
                    HStack(alignment: .top, spacing: 8) {
                        Circle().fill(Theme.ember).frame(width: 5, height: 5).padding(.top, 6)
                        Text(goal)
                            .font(.system(size: 12.5))
                            .foregroundStyle(Theme.chalkDim)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(isCurrent ? Theme.ember.opacity(0.55) : Theme.hairline, lineWidth: isCurrent ? 1.5 : 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}
