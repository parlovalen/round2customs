//
//  WorkoutTimers.swift
//  RecompCoach
//
//  Timers for the guided logger: a rest countdown between sets (all exercises)
//  and a hold countdown for genuinely timed isometrics (planks, wall sits).
//  Both share one wall-clock-based engine so the countdown stays accurate even
//  if the run loop pauses (during a scroll) or the app is briefly backgrounded.
//

import SwiftUI
import UIKit

// MARK: - Countdown engine

/// A one-shot countdown driven by a real deadline (not by counting ticks), so it
/// can't drift. Fires `onComplete` and a success haptic when it reaches zero.
@Observable final class IntervalTimer {
    private(set) var total: Int = 0        // starting seconds
    private(set) var remaining: Int = 0    // seconds left
    private(set) var isRunning = false

    /// Called on the main thread the moment the countdown reaches zero.
    var onComplete: (() -> Void)?

    private var deadline: Date?
    private var ticker: Timer?

    var elapsed: Int { max(0, total - remaining) }
    var progress: Double { total > 0 ? Double(elapsed) / Double(total) : 0 }

    /// "m:ss" for the rest overlay.
    var clock: String {
        let s = max(0, remaining)
        return String(format: "%d:%02d", s / 60, s % 60)
    }

    /// Begin a fresh countdown of `seconds`.
    func start(seconds: Int) {
        total = max(1, seconds)
        remaining = total
        resume()
    }

    func resume() {
        guard !isRunning, remaining > 0 else { return }
        isRunning = true
        deadline = Date().addingTimeInterval(TimeInterval(remaining))
        schedule()
    }

    func pause() {
        isRunning = false
        ticker?.invalidate(); ticker = nil
        deadline = nil
    }

    /// Fully reset back to idle.
    func stop() {
        pause()
        total = 0; remaining = 0
    }

    /// Nudge the countdown by `delta` seconds (used by the ±15 rest buttons).
    func adjust(by delta: Int) {
        remaining = max(0, remaining + delta)
        total = max(total, remaining)
        if isRunning { deadline = Date().addingTimeInterval(TimeInterval(remaining)) }
        if remaining == 0 { finish() }
    }

    private func schedule() {
        ticker?.invalidate()
        // .common mode keeps it firing while the user scrolls or interacts.
        let t = Timer(timeInterval: 0.2, repeats: true) { [weak self] _ in self?.tick() }
        RunLoop.main.add(t, forMode: .common)
        ticker = t
    }

    private func tick() {
        guard let deadline else { return }
        remaining = max(0, Int(ceil(deadline.timeIntervalSinceNow)))
        if remaining == 0 { finish() }
    }

    private func finish() {
        pause()
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        onComplete?()
    }
}

// MARK: - Rest timer (inline, between sets)

/// An on-page rest countdown shown after "Next set" — a card that sits in the
/// scroll flow (not a modal). Auto-dismisses at zero.
struct RestTimerBar: View {
    @Bindable var timer: IntervalTimer
    var onDone: () -> Void

    private var remainingFraction: Double {
        timer.total > 0 ? Double(timer.remaining) / Double(timer.total) : 0
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "timer")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(Theme.ember)
                Text("REST")
                    .font(.system(size: 12, weight: .bold))
                    .tracking(2)
                    .foregroundStyle(Theme.chalkDim)
                Spacer()
                Text(timer.clock)
                    .font(Theme.pixel(30))
                    .foregroundStyle(Theme.chalk)
                    .monospacedDigit()
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.white.opacity(0.10))
                    Capsule().fill(Theme.ember).frame(width: max(0, geo.size.width * remainingFraction))
                }
            }
            .frame(height: 6)

            HStack(spacing: 10) {
                pill("−15") { timer.adjust(by: -15) }
                pill("+15") { timer.adjust(by: 15) }
                Button {
                    timer.isRunning ? timer.pause() : timer.resume()
                } label: {
                    Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(Theme.chalk)
                        .frame(width: 40, height: 34)
                        .background(RoundedRectangle(cornerRadius: 10).fill(Theme.iron2))
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.hairline, lineWidth: 1))
                }
                .buttonStyle(.plain)
                Spacer()
                Button(action: onDone) {
                    Text("Skip")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 18)
                        .background(Theme.ember)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.cardRadius)
                .stroke(Theme.ember.opacity(0.4), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
        .onChange(of: timer.remaining) { _, r in
            if r == 0 && timer.total > 0 { onDone() }
        }
    }

    private func pill(_ label: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(Theme.mono(14, weight: .semibold))
                .foregroundStyle(Theme.chalk)
                .frame(width: 48, height: 34)
                .background(RoundedRectangle(cornerRadius: 10).fill(Theme.iron2))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Hold timer (timed isometrics)

/// Inline countdown for a timed hold (plank, wall sit). Set a target with ±5,
/// tap Start, and it logs the seconds held into the set on completion (or the
/// elapsed time if stopped early).
struct HoldTimerControl: View {
    @Binding var holdText: String
    let defaultTarget: Int

    @State private var target: Int
    @State private var timer = IntervalTimer()
    @State private var justLogged = false

    init(holdText: Binding<String>, defaultTarget: Int) {
        _holdText = holdText
        self.defaultTarget = defaultTarget
        let seed = Int(holdText.wrappedValue) ?? defaultTarget
        _target = State(initialValue: max(5, seed))
    }

    var body: some View {
        VStack(spacing: 18) {
            CircularRing(
                progress: timer.isRunning ? timer.progress : (justLogged ? 1 : 0),
                lineWidth: 12,
                arcColor: justLogged ? Theme.moss : Theme.ember
            ) {
                VStack(spacing: 2) {
                    Text(timer.isRunning ? "\(timer.remaining)" : "\(target)")
                        .font(Theme.pixel(50))
                        .foregroundStyle(Theme.chalk)
                    Text("sec")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(Theme.chalkDim)
                }
            }
            .frame(width: 190, height: 190)

            if timer.isRunning {
                Button(action: stopEarly) {
                    HStack(spacing: 8) {
                        Image(systemName: "stop.fill")
                        Text("Stop")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(SteelButtonStyle())
            } else {
                HStack(spacing: 16) {
                    step("minus") { target = max(5, target - 5) }
                    Button(action: startHold) {
                        HStack(spacing: 8) {
                            Image(systemName: "play.fill")
                            Text(justLogged ? "Hold again" : "Start hold")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SteelButtonStyle())
                    step("plus") { target += 5 }
                }
            }

            if justLogged {
                Text("Logged \(holdText)s ✓")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.moss)
            }
        }
        .onAppear { timer.onComplete = completed }
        .onDisappear { timer.stop() }
    }

    private func step(_ icon: String, _ action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Theme.chalk)
                .frame(width: 52, height: 52)
                .background(Circle().fill(Theme.iron2))
                .overlay(Circle().stroke(Theme.hairline, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func startHold() {
        justLogged = false
        timer.start(seconds: target)
    }

    private func completed() {
        holdText = String(target)
        justLogged = true
    }

    private func stopEarly() {
        let held = timer.elapsed
        timer.stop()
        if held > 0 {
            holdText = String(held)
            justLogged = true
        }
    }
}
