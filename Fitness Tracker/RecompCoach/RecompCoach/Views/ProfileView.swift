//
//  ProfileView.swift
//  RecompCoach
//
//  Profile menu, opened by tapping the avatar in the app header: a photo
//  card up top, then rows into My Info, Integrations, Notifications, and
//  Backup & Restore — each its own pushed screen with its own save/autosave.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProfileView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]

    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?

    private var profile: UserProfile? { profiles.first }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    photoCard
                    navRow(icon: "person.text.rectangle.fill", title: "My Info", subtitle: "About you and nutrition targets") {
                        MyInfoView()
                    }
                    navRow(icon: "arrow.left.arrow.right", title: "Integrations", subtitle: "Connected apps and data sync") {
                        IntegrationsView()
                    }
                    navRow(icon: "bell.fill", title: "Notifications", subtitle: "Reminders and coaching alerts") {
                        NotificationsSettingsView()
                    }
                    navRow(icon: "externaldrive.fill", title: "Backup & Restore", subtitle: "Export, restore, or reset your data") {
                        BackupRestoreView()
                    }
                }
                .padding(16)
                .padding(.bottom, 40)
            }
            .background(Theme.charcoal)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .onAppear { photoData = profile?.photoData }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self) {
                        let downscaled = Self.downscaled(data)
                        photoData = downscaled
                        savePhoto(downscaled)
                    }
                }
            }
        }
    }

    // MARK: Photo

    private var photoCard: some View {
        VStack(spacing: 12) {
            AvatarView(photoData: photoData, diameter: 96)
            PhotosPicker(selection: $photoItem, matching: .images) {
                Text(photoData == nil ? "Add photo" : "Change photo")
            }
            .buttonStyle(GhostButtonStyle())
        }
        .frame(maxWidth: .infinity)
        .card()
    }

    private func savePhoto(_ data: Data?) {
        let p = profile ?? {
            let new = UserProfile()
            context.insert(new)
            return new
        }()
        p.photoData = data
        try? context.save()
    }

    /// Downscale + JPEG-compress a picked photo so it stays cheap to store.
    private static func downscaled(_ data: Data, maxDimension: CGFloat = 600, quality: CGFloat = 0.8) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return image.jpegData(compressionQuality: quality) }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: quality)
    }

    // MARK: Nav rows

    private func navRow<Destination: View>(
        icon: String, title: String, subtitle: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Theme.ember)
                    .frame(width: 26)
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Theme.chalk)
                    Text(subtitle)
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.chalkDim)
                }
                Spacer(minLength: 0)
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Theme.chalkDim)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .card()
        }
        .buttonStyle(.plain)
    }
}
