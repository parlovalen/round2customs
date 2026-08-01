//
//  ExerciseLibraryView.swift
//  RecompCoach
//
//  The full exercise library: browse all 40 unique exercises used across the
//  52-week program, filterable by muscle group and searchable by name, with
//  a detail screen (image, cues, mistakes, modifications, a form-video
//  search link). Opened two ways: as a general browse (from a rest day, or
//  the Workout tab's chip list — `current` nil), or as a mid-set "Switch"
//  flow (`current` set), where the detail screen gains a "Swap in" button
//  that replaces that exercise in the in-progress `WorkoutDraft`.
//
//  Both flows also offer a "Full Library" source — ~675 exercises imported
//  from the public free-exercise-db dataset (`PublicExerciseCatalog`). These
//  carry no authored prescription/tempo/RPE, so swapping one in goes through
//  `ReferenceExerciseDef.asExerciseDef()`, which synthesizes generic
//  hypertrophy defaults (3 × 8–12, 90s rest) — the imported `instructions`
//  become the coaching cues, since those are genuinely exercise-specific.
//

import SwiftUI

private enum LibrarySource {
    case program, full
}

struct ExerciseLibrarySheet: View {
    /// The exercise being swapped, when opened from an in-progress exercise.
    /// Nil when opened as a general library browse.
    var current: ExerciseDef? = nil
    /// Called with the chosen replacement when swapping. Nil in browse mode.
    var onSwap: ((ExerciseDef) -> Void)? = nil

    @Environment(\.dismiss) private var dismiss
    @State private var source: LibrarySource = .program
    @State private var selectedGroup: MuscleGroup?
    @State private var searchText = ""
    @State private var detailExercise: ExerciseDef?
    @State private var detailReference: ReferenceExerciseDef?

    init(current: ExerciseDef? = nil, onSwap: ((ExerciseDef) -> Void)? = nil) {
        self.current = current
        self.onSwap = onSwap
        // Mid-workout, default the muscle-group filter to whatever's being
        // replaced rather than "All" — you're switching out a leg exercise
        // for another leg exercise, not browsing from scratch.
        _selectedGroup = State(initialValue: current.map { ExerciseLibrary.muscleGroup(for: $0) })
    }

    private var filtered: [ExerciseDef] {
        ExerciseLibrary.allExercises.filter { ex in
            (selectedGroup == nil || ExerciseLibrary.muscleGroup(for: ex) == selectedGroup)
                && (searchText.isEmpty || ex.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var filteredReference: [ReferenceExerciseDef] {
        PublicExerciseCatalog.all.filter { ex in
            (selectedGroup == nil || PublicExerciseCatalog.muscleGroup(for: ex) == selectedGroup)
                && (searchText.isEmpty || ex.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                sourceToggle
                searchField
                groupChips
                ScrollView {
                    switch source {
                    case .program:
                        // Plain VStack, not LazyVStack — only ~38 rows total, and
                        // LazyVStack's deferred off-screen instantiation was
                        // producing a layout gap that only resolved on scroll.
                        VStack(spacing: 10) {
                            if filtered.isEmpty {
                                emptyState
                            } else {
                                ForEach(filtered) { ex in
                                    Button { detailExercise = ex } label: { row(ex) }
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    case .full:
                        // LazyVStack here — ~675 rows, each with its own async
                        // photo fetch, so eager instantiation would fire them
                        // all at once instead of only as rows scroll on-screen.
                        LazyVStack(spacing: 10) {
                            if filteredReference.isEmpty {
                                emptyState
                            } else {
                                ForEach(filteredReference) { ex in
                                    Button { detailReference = ex } label: { referenceRow(ex) }
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 24)
                    }
                }
            }
            .padding(.top, 12)
            .background(Theme.charcoal)
            .dismissKeyboardOnTap()
            .navigationTitle(current == nil ? "Exercise Library" : "Switch Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .navigationDestination(item: $detailExercise) { ex in
                ExerciseDetailView(
                    exercise: ex,
                    current: current,
                    // Closes this sheet, then hands off to the caller's swap handler.
                    onSwap: onSwap.map { handler in
                        { (chosen: ExerciseDef) in
                            dismiss()
                            handler(chosen)
                        }
                    }
                )
            }
            .navigationDestination(item: $detailReference) { ex in
                ReferenceExerciseDetailView(
                    exercise: ex,
                    current: current,
                    onSwap: onSwap.map { handler in
                        { (chosen: ExerciseDef) in
                            dismiss()
                            handler(chosen)
                        }
                    }
                )
            }
        }
        .presentationDetents([.large])
    }

    private var sourceToggle: some View {
        HStack(spacing: 8) {
            sourceButton(.program, label: "Program")
            sourceButton(.full, label: "Full Library")
        }
        .padding(.horizontal, 16)
    }

    private func sourceButton(_ value: LibrarySource, label: String) -> some View {
        let isSelected = source == value
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { source = value }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x151515) : Theme.chalkDim)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(isSelected ? Theme.ember : Theme.iron2)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
        }
        .buttonStyle(.plain)
    }

    private var searchField: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
            TextField("Search exercises", text: $searchText)
                .font(.system(size: 14))
                .foregroundStyle(Theme.chalk)
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(Theme.iron2)
        .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Theme.fieldRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .padding(.horizontal, 16)
    }

    private var groupChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chip(nil, label: "All")
                ForEach(MuscleGroup.allCases) { group in
                    chip(group, label: group.rawValue)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func chip(_ group: MuscleGroup?, label: String) -> some View {
        let isSelected = selectedGroup == group
        return Button {
            withAnimation(.easeInOut(duration: 0.15)) { selectedGroup = group }
        } label: {
            Text(label)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(isSelected ? Color(hex: 0x151515) : Theme.chalkDim)
                .padding(.vertical, 8)
                .padding(.horizontal, 14)
                .background(isSelected ? Theme.ember : Theme.iron2)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func row(_ ex: ExerciseDef) -> some View {
        libraryRow(
            name: ex.name,
            subtitle: ExerciseLibrary.muscleGroup(for: ex).rawValue + " · " + ex.targetMuscles.joined(separator: ", "),
            imageURL: ImageProvider.exerciseURL(ex)
        )
    }

    private func referenceRow(_ ex: ReferenceExerciseDef) -> some View {
        libraryRow(
            name: ex.name,
            subtitle: PublicExerciseCatalog.muscleGroup(for: ex).rawValue + (ex.equipment.map { " · " + $0.capitalized } ?? ""),
            imageURL: PublicExerciseCatalog.imageURL(for: ex)
        )
    }

    private func libraryRow(name: String, subtitle: String, imageURL: URL?) -> some View {
        HStack(spacing: 12) {
            // A direct `.frame()` on RemoteImageView doesn't reliably cap the
            // AsyncImage's rendered size — the Color.clear+overlay wrapper
            // (matching ExerciseDetailView.exerciseImage) is what actually works.
            Color.clear
                .frame(width: 56, height: 56)
                .overlay {
                    RemoteImageView(url: imageURL, icon: "dumbbell.fill", cornerRadius: 0, bordered: false)
                }
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .stroke(Theme.hairline, lineWidth: 1)
                )
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Theme.chalk)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.system(size: 11.5))
                    .foregroundStyle(Theme.chalkDim)
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Image(systemName: "chevron.right")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(Theme.chalkDim)
        }
        .padding(10)
        .background(Theme.iron)
        .overlay(
            RoundedRectangle(cornerRadius: Theme.fieldRadius)
                .stroke(Theme.hairline, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 26, weight: .light))
                .foregroundStyle(Theme.chalkDim.opacity(0.5))
            Text("No exercises match.")
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalkDim)
        }
        .frame(maxWidth: .infinity, minHeight: 140)
        .padding(.top, 40)
    }
}

// MARK: - Exercise detail

private struct ExerciseDetailView: View {
    let exercise: ExerciseDef
    var current: ExerciseDef?
    var onSwap: ((ExerciseDef) -> Void)?

    private var isCurrent: Bool { current?.id == exercise.id }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                exerciseImage
                groupPill
                SectionCard(title: "Targets", subtitle: nil) {
                    Text(exercise.targetMuscles.joined(separator: " · "))
                        .font(.system(size: 13.5))
                        .foregroundStyle(Theme.chalkDim)
                }
                SectionCard(title: "Coaching Cues", subtitle: nil) {
                    bulletList(exercise.coachingCues, color: Theme.ember)
                }
                SectionCard(title: "Common Mistakes", subtitle: nil) {
                    bulletList(exercise.commonMistakes, color: Theme.rust)
                }
                SectionCard(title: "Modifications", subtitle: nil) {
                    VStack(spacing: 10) {
                        modRow("Beginner", exercise.beginnerModification)
                        Divider().overlay(Theme.hairline)
                        modRow("Advanced", exercise.advancedProgression)
                    }
                }
                videoButton
                if let onSwap, !isCurrent {
                    Button {
                        onSwap(exercise)
                    } label: {
                        Text("Swap in for \(current?.name ?? "current exercise")")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SteelButtonStyle())
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    /// Fixed-height, hard-clipped photo box so the scaledToFill image can't
    /// collapse to its intrinsic (narrow) width inside the VStack — mirrors
    /// `ExerciseLogView.exerciseImage`.
    private var exerciseImage: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .overlay {
                RemoteImageView(url: ImageProvider.exerciseURL(exercise), icon: "dumbbell.fill", cornerRadius: 0, bordered: false)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }

    private var groupPill: some View {
        HStack {
            Text(ExerciseLibrary.muscleGroup(for: exercise).rawValue.uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundStyle(Color(hex: 0x151515))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
                .background(Theme.ember)
                .clipShape(Capsule())
            Spacer()
        }
    }

    private func bulletList(_ items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Circle().fill(color).frame(width: 5, height: 5).padding(.top, 6)
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func modRow(_ label: String, _ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label.uppercased())
                .font(.system(size: 11, weight: .semibold))
                .tracking(0.4)
                .foregroundStyle(Theme.chalkDim)
            Text(text)
                .font(.system(size: 13))
                .foregroundStyle(Theme.chalk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var videoButton: some View {
        if let url = videoSearchURL {
            Link(destination: url) {
                Label("Watch form video", systemImage: "play.rectangle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    private var videoSearchURL: URL? {
        var comps = URLComponents(string: "https://www.youtube.com/results")
        comps?.queryItems = [URLQueryItem(name: "search_query", value: exercise.videoKeywords)]
        return comps?.url
    }
}

// MARK: - Reference (Full Library) exercise detail

/// Detail screen for a Full Library exercise. Reference-only — no coaching
/// cues, mistakes, or modifications (the imported dataset doesn't carry
/// those), and no "Swap in" (see the note at the top of this file).
private struct ReferenceExerciseDetailView: View {
    let exercise: ReferenceExerciseDef
    var current: ExerciseDef?
    var onSwap: ((ExerciseDef) -> Void)?

    private var isCurrent: Bool { current?.id == "ref_\(exercise.id)" }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                exerciseImage
                pills
                if !exercise.secondaryMuscles.isEmpty {
                    SectionCard(title: "Also Works", subtitle: nil) {
                        Text(exercise.secondaryMuscles.map { $0.capitalized }.joined(separator: " · "))
                            .font(.system(size: 13.5))
                            .foregroundStyle(Theme.chalkDim)
                    }
                }
                SectionCard(title: "How To", subtitle: nil) {
                    numberedList(exercise.instructions)
                }
                videoButton
                if let onSwap, !isCurrent {
                    Button {
                        onSwap(exercise.asExerciseDef())
                    } label: {
                        Text("Swap in for \(current?.name ?? "current exercise")")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SteelButtonStyle())
                }
            }
            .padding(16)
            .padding(.bottom, 40)
        }
        .background(Theme.charcoal)
        .navigationTitle(exercise.name)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var exerciseImage: some View {
        Color.clear
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .overlay {
                RemoteImageView(url: PublicExerciseCatalog.imageURL(for: exercise), icon: "dumbbell.fill", cornerRadius: 0, bordered: false)
            }
            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.cardRadius)
                    .stroke(Theme.hairline, lineWidth: 1)
            )
    }

    private var pills: some View {
        HStack(spacing: 8) {
            pill(PublicExerciseCatalog.muscleGroup(for: exercise).rawValue.uppercased())
            if let equipment = exercise.equipment {
                pill(equipment.capitalized.uppercased())
            }
            pill(exercise.level.capitalized.uppercased())
            Spacer()
        }
    }

    private func pill(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(Color(hex: 0x151515))
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Theme.ember)
            .clipShape(Capsule())
    }

    private func numberedList(_ items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                HStack(alignment: .top, spacing: 8) {
                    Text("\(index + 1)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Theme.ember)
                        .frame(width: 16, alignment: .leading)
                    Text(item)
                        .font(.system(size: 13))
                        .foregroundStyle(Theme.chalkDim)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder private var videoButton: some View {
        if let url = videoSearchURL {
            Link(destination: url) {
                Label("Watch form video", systemImage: "play.rectangle.fill")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(GhostButtonStyle())
        }
    }

    private var videoSearchURL: URL? {
        var comps = URLComponents(string: "https://www.youtube.com/results")
        comps?.queryItems = [URLQueryItem(name: "search_query", value: exercise.name)]
        return comps?.url
    }
}
