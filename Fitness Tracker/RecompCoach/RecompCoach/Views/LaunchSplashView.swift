//
//  LaunchSplashView.swift
//  RecompCoach
//
//  Animated launch screen: logomark scales/fades in over the glow background,
//  holds briefly, then the app fades it out to reveal RootView underneath.
//  Driven entirely by RecompCoachApp's timer — this view only owns the
//  entrance animation.
//

import SwiftUI

struct LaunchSplashView: View {
    @State private var logoScale: CGFloat = 0.3
    @State private var logoRotation: Double = -14
    @State private var logoOpacity: Double = 0
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            GlowBackground()
            RadialGradient(
                colors: [Theme.ember.opacity(0.35), .clear],
                center: .center, startRadius: 10, endRadius: 340
            )
            .opacity(glowOpacity)
            Image("Logomark")
                .resizable()
                .scaledToFit()
                .frame(height: 150)
                .scaleEffect(logoScale)
                .rotationEffect(.degrees(logoRotation))
                .opacity(logoOpacity)
        }
        .onAppear {
            // Bouncy two-stage pop: overshoot past full size/upright, then a
            // quick second spring settles it back — reads as the mark landing
            // with a little life, rather than a flat fade-in.
            logoOpacity = 1
            withAnimation(.spring(response: 0.5, dampingFraction: 0.55)) {
                logoScale = 1.15
                logoRotation = 5
            }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.65).delay(0.28)) {
                logoScale = 1
                logoRotation = 0
            }
            withAnimation(.easeOut(duration: 0.7)) {
                glowOpacity = 1
            }
        }
    }
}
