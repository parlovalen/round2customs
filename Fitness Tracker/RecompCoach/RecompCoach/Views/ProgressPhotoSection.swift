//
//  ProgressPhotoSection.swift
//  RecompCoach
//
//  My Info's "Progress Photos" section: a horizontal filmstrip of captures
//  with a leading "Add" tile, and a full-screen detail/delete sheet per photo.
//

import SwiftUI
import SwiftData
import PhotosUI

struct ProgressPhotosSection: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ProgressPhoto.date, order: .reverse) private var photos: [ProgressPhoto]

    @State private var pickerItem: PhotosPickerItem?
    @State private var selectedPhoto: ProgressPhoto?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if photos.isEmpty {
                Text("No photos yet. Add one to start the trend — a monthly reminder is on by default (Notifications settings).")
                    .font(.system(size: 12.5))
                    .foregroundStyle(Theme.chalkDim)
            }
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    addTile
                    ForEach(photos) { photo in
                        thumbnail(photo)
                    }
                }
            }
        }
        .sheet(item: $selectedPhoto) { photo in
            ProgressPhotoDetailSheet(photo: photo)
        }
        .onChange(of: pickerItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self),
                      let downscaled = Self.downscaled(data) else { return }
                context.insert(ProgressPhoto(date: .now, photoData: downscaled))
                try? context.save()
                pickerItem = nil
            }
        }
    }

    private var addTile: some View {
        PhotosPicker(selection: $pickerItem, matching: .images) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .strokeBorder(Theme.hairline, style: StrokeStyle(lineWidth: 1, dash: [4]))
                        .background(RoundedRectangle(cornerRadius: Theme.fieldRadius).fill(Theme.iron2))
                        .frame(width: 78, height: 78)
                    Image(systemName: "plus")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(Theme.ember)
                }
                Text("Add")
                    .font(.system(size: 10.5))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .buttonStyle(.plain)
    }

    private func thumbnail(_ photo: ProgressPhoto) -> some View {
        Button {
            selectedPhoto = photo
        } label: {
            VStack(spacing: 6) {
                Group {
                    if let uiImage = UIImage(data: photo.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                    } else {
                        Theme.iron2
                    }
                }
                .frame(width: 78, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: Theme.fieldRadius))
                .overlay(
                    RoundedRectangle(cornerRadius: Theme.fieldRadius)
                        .stroke(Theme.hairline, lineWidth: 1)
                )
                Text(photo.date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.system(size: 10.5))
                    .foregroundStyle(Theme.chalkDim)
            }
        }
        .buttonStyle(.plain)
    }

    /// Downscale + JPEG-compress a picked photo — larger than the avatar crop
    /// since these are viewed full-screen for visual before/after comparison.
    private static func downscaled(_ data: Data, maxDimension: CGFloat = 1200, quality: CGFloat = 0.85) -> Data? {
        guard let image = UIImage(data: data) else { return data }
        let size = image.size
        let scale = min(1, maxDimension / max(size.width, size.height))
        guard scale < 1 else { return image.jpegData(compressionQuality: quality) }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        let resized = renderer.image { _ in image.draw(in: CGRect(origin: .zero, size: newSize)) }
        return resized.jpegData(compressionQuality: quality)
    }
}

// MARK: - Detail / delete sheet

private struct ProgressPhotoDetailSheet: View {
    @Bindable var photo: ProgressPhoto
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showDeleteConfirm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    if let uiImage = UIImage(data: photo.photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: Theme.cardRadius))
                    }
                    NotesField(label: "Notes", placeholder: "Optional", text: $photo.notes)
                    Button("Delete photo") { showDeleteConfirm = true }
                        .buttonStyle(GhostButtonStyle())
                        .frame(maxWidth: .infinity)
                }
                .padding(16)
            }
            .background(Theme.charcoal)
            .navigationTitle(photo.date.formatted(.dateTime.month(.wide).day().year()))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .confirmationDialog(
                "Delete this photo? This can't be undone.",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    context.delete(photo)
                    try? context.save()
                    dismiss()
                }
            }
        }
    }
}
