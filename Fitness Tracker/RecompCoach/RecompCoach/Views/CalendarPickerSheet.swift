//
//  CalendarPickerSheet.swift
//  RecompCoach
//
//  Full month calendar, dropped down from the header's "Today ▾" button (a
//  popover anchored under it, not a sheet sliding up from the bottom). Picking
//  a day updates the shared `AppRouter.selectedDate` that Home's stat chips,
//  workout card, and meal card all read from.
//

import SwiftUI

struct CalendarPickerSheet: View {
    @Binding var selection: Date

    @Environment(\.dismiss) private var dismiss
    @State private var picked: Date

    init(selection: Binding<Date>) {
        self._selection = selection
        self._picked = State(initialValue: selection.wrappedValue)
    }

    private let corner: CGFloat = 24

    var body: some View {
        VStack(spacing: 14) {
            DatePicker("", selection: $picked, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Theme.ember)
                .colorScheme(.dark)
                .labelsHidden()
                .frame(width: 300)

            Button("Jump to Today") {
                picked = Calendar.current.startOfDay(for: .now)
            }
            .buttonStyle(GhostButtonStyle())
        }
        .padding(14)
        .glassCard(cornerRadius: corner)
        .onChange(of: picked) { _, new in
            selection = Calendar.current.startOfDay(for: new)
            dismiss()
        }
    }
}

private extension View {
    /// Liquid Glass surface (iOS 26+) with the shared glass-edge stroke on
    /// top, so the calendar reads as a floating glass card rather than a flat
    /// panel. Falls back to the app's usual iron card + the same stroke on
    /// older OS versions.
    @ViewBuilder
    func glassCard(cornerRadius: CGFloat) -> some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        if #available(iOS 26.0, *) {
            self
                .glassEffect(.regular, in: shape)
                .overlay(shape.stroke(Theme.glassStroke, lineWidth: 1.2))
        } else {
            self
                .background(Theme.iron)
                .clipShape(shape)
                .overlay(shape.stroke(Theme.glassStroke, lineWidth: 1.2))
        }
    }
}
