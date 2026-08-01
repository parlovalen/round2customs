//
//  Components.swift
//  RecompCoach
//
//  Small reusable building blocks shared across screens.
//

import SwiftUI
import UIKit

// MARK: - Keyboard dismissal

extension View {
    /// Dismisses the keyboard on a tap anywhere in this view. Added as a
    /// `simultaneousGesture` (not exclusive), so it never blocks taps on
    /// buttons, fields, or other controls underneath — it just also resigns
    /// first responder whenever any tap lands.
    func dismissKeyboardOnTap() -> some View {
        simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        )
    }
}

// MARK: - Card with a heading

/// An iron card with a display heading and optional subtitle.
struct SectionCard<Content: View>: View {
    let title: String
    var subtitle: String? = nil
    @ViewBuilder var content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text(title).displayHeading()
                    .foregroundStyle(Theme.chalk)
                if let subtitle {
                    Text(subtitle)
                        .font(.system(size: 12.5))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

// MARK: - Labeled fields

/// A labeled text field styled like the prototype's inputs, bound to a String.
struct LabeledField: View {
    let label: String
    var placeholder: String = ""
    var keyboard: UIKeyboardType = .default
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.chalkDim)
            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(Theme.mono(14))
                .foregroundStyle(Theme.chalk)
                .padding(.vertical, 10)
                .padding(.horizontal, 11)
                .background(Theme.iron2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .stroke(Theme.hairline, lineWidth: 1)
                )
        }
    }
}

/// Multi-line notes field.
struct NotesField: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(Theme.chalkDim)
            TextField(placeholder, text: $text, axis: .vertical)
                .lineLimit(2...5)
                .font(.system(size: 14))
                .foregroundStyle(Theme.chalk)
                .padding(.vertical, 10)
                .padding(.horizontal, 11)
                .background(Theme.iron2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .stroke(Theme.hairline, lineWidth: 1)
                )
        }
    }
}

// MARK: - Week streak dots

struct WeekStreakDots: View {
    /// One bool per day of the current week, true = logged.
    let logged: [Bool]

    var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(logged.enumerated()), id: \.offset) { _, done in
                RoundedRectangle(cornerRadius: 4)
                    .fill(done ? Theme.moss : Theme.iron2)
                    .frame(width: 18, height: 18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(done ? Theme.moss : Theme.hairline, lineWidth: 1)
                    )
            }
        }
    }
}

// MARK: - Stat tile

// MARK: - Toast

/// Transient confirmation pill, anchored to the bottom of a screen.
struct ToastView: View {
    let text: String?
    var body: some View {
        if let text {
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(hex: 0x151515))
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(Theme.moss)
                .clipShape(Capsule())
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }
}

/// A compact labeled metric tile, e.g. calories / protein target.
struct StatTile: View {
    let label: String
    let value: String
    var accent: Color = Theme.chalk

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.4)
                .textCase(.uppercase)
                .foregroundStyle(Theme.chalkDim)
            Text(value)
                .font(Theme.pixel(24))
                .foregroundStyle(accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Theme.iron2)
        .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
    }
}
