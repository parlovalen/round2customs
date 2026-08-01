//
//  Theme.swift
//  RecompCoach
//
//  Design system styled after ref-app-2: a near-black canvas with a warm orange
//  glow, vivid ember-orange as the primary accent, warm-dark cards, and pixel
//  (dot-matrix) numerals for the big display values. Property names are kept
//  stable so all screens pick up the new look automatically.
//

import SwiftUI

enum Theme {

    // MARK: - Palette (ref-app-2)

    static let charcoal  = Color(hex: 0x0C0A09) // app background (near-black, warm)
    static let iron      = Color(hex: 0x17120F) // card background (warm dark)
    static let iron2     = Color(hex: 0x221B16) // inset / field background
    static let chalk     = Color(hex: 0xF6F1EB) // primary text
    static let chalkDim  = Color(hex: 0x8C8279) // secondary text

    /// Primary accent — ember orange. (Named `steel` for source compatibility.)
    static let steel     = Color(hex: 0xEE5A24)
    static let ember     = Color(hex: 0xEE5A24)
    static let emberDeep = Color(hex: 0xC33C12)

    static let rust      = Color(hex: 0xD6442E) // warning / high knee-pain (red-orange)
    static let moss      = Color(hex: 0x6FA043) // success / "OK" (green)
    static let water     = Color(hex: 0x4FA8E0) // hydration (the one intentional cool accent)
    static let violet    = Color(hex: 0x9B7EDE) // sleep accent

    static let hairline  = Color(hex: 0xF6F1EB, opacity: 0.06)

    /// Warm gradient used on hero cards.
    static var heroGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0x5A2E17), Color(hex: 0x241813), Color(hex: 0x17120F)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    /// Solid ember gradient for streak / emphasis cards.
    static var emberGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0xF16A2E), Color(hex: 0xC93B12)],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }

    // MARK: - Metrics

    static let cardRadius: CGFloat = 20
    static let fieldRadius: CGFloat = 12

    // MARK: - Typography

    /// Title face — clean sentence-case sans (system).
    static func display(_ size: CGFloat, weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight, design: .default)
    }

    /// Small monospaced numerics for dense values.
    static func mono(_ size: CGFloat, weight: Font.Weight = .medium) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }

    /// Big display numerals — a sleek, modern sans-serif (SF Pro). Name kept as
    /// `pixel` for source compatibility with the many call sites.
    static func pixel(_ size: CGFloat) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

// MARK: - Reusable view styling

extension Theme {
    /// Liquid-glass edge-highlight stroke: bright white catching the
    /// top-leading corner, fading through a faint ember tint, like light
    /// catching the rim of glass. Used on the calendar popover.
    static var glassStroke: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.55),
                .white.opacity(0.12),
                Theme.ember.opacity(0.25),
                .white.opacity(0.08)
            ],
            startPoint: .topLeading, endPoint: .bottomTrailing
        )
    }
}

/// The standard warm-dark card container.
struct CardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(18)
            .background(Theme.iron)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
    }
}

extension View {
    func card() -> some View { modifier(CardModifier()) }

    /// Section heading — sentence case, medium weight (ref-app-2 style).
    func displayHeading(_ size: CGFloat = 17, weight: Font.Weight = .semibold) -> some View {
        self.font(Theme.display(size, weight: weight))
    }

    /// Blur this content while a sheet/popover is presented over it, so the
    /// background reads as backgrounded rather than just dimmed. Apply to
    /// whatever sits behind a `.sheet`/`.popover` call.
    func blurredWhenPresenting(_ isPresented: Bool) -> some View {
        self
            .blur(radius: isPresented ? 14 : 0)
            .animation(.easeOut(duration: 0.22), value: isPresented)
    }
}

/// Primary action button — solid ember orange.
struct SteelButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(Theme.display(16, weight: .semibold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(Theme.ember)
            .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
            .opacity(configuration.isPressed ? 0.85 : 1)
    }
}

/// Secondary / ghost button.
struct GhostButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Theme.chalkDim)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Theme.iron2)
            .overlay(
                RoundedRectangle(cornerRadius: Theme.fieldRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

// MARK: - Ambient glow background

/// Near-black canvas with a warm orange radial glow in the corners (ref-app-2).
struct GlowBackground: View {
    var body: some View {
        ZStack {
            Theme.charcoal
            RadialGradient(
                colors: [Theme.ember.opacity(0.28), .clear],
                center: .init(x: 0.95, y: 0.05), startRadius: 4, endRadius: 380
            )
            RadialGradient(
                colors: [Theme.emberDeep.opacity(0.20), .clear],
                center: .init(x: 0.05, y: 1.0), startRadius: 4, endRadius: 420
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Circular progress ring

/// A ring with a dark track, an ember arc, and a dot at the arc's end — used for
/// the hero "daily process" and other completion indicators. Standard size/
/// thickness (130pt / 6pt, set by the Activity card) are the defaults going
/// forward; pass `diameter`/`lineWidth` to override for a specific spot.
struct CircularRing<Center: View>: View {
    var progress: Double            // 0...1
    var diameter: CGFloat = 130
    var lineWidth: CGFloat = 6
    var trackColor: Color = Color(hex: 0xF6F1EB, opacity: 0.10)
    var arcColor: Color = Theme.ember
    @ViewBuilder var center: () -> Center

    var body: some View {
        let clamped = max(0, min(1, progress))
        ZStack {
            Circle().stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: clamped)
                .stroke(arcColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            GeometryReader { geo in
                let r = min(geo.size.width, geo.size.height) / 2
                let angle = Angle.degrees(-90 + 360 * clamped)
                Circle()
                    .fill(.white)
                    .frame(width: lineWidth + 4, height: lineWidth + 4)
                    .position(
                        x: geo.size.width / 2 + r * cos(angle.radians),
                        y: geo.size.height / 2 + r * sin(angle.radians)
                    )
                    .opacity(clamped > 0 ? 1 : 0)
            }
            center()
        }
        .frame(width: diameter, height: diameter)
    }
}
