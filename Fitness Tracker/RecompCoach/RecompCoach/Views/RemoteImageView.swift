//
//  RemoteImageView.swift
//  RecompCoach
//
//  AsyncImage wrapper with an on-brand placeholder (warm gradient + icon) shown
//  while loading or when offline / the fetch fails.
//

import SwiftUI

struct RemoteImageView: View {
    let url: URL?
    var icon: String = "photo"
    var cornerRadius: CGFloat = Theme.fieldRadius
    var bordered: Bool = true

    var body: some View {
        AsyncImage(url: url, transaction: Transaction(animation: .easeIn(duration: 0.25))) { phase in
            switch phase {
            case .success(let image):
                image.resizable().scaledToFill()
            case .empty:
                placeholder(loading: true)
            case .failure:
                placeholder(loading: false)
            @unknown default:
                placeholder(loading: false)
            }
        }
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(Theme.hairline, lineWidth: bordered ? 1 : 0)
        )
    }

    private func placeholder(loading: Bool) -> some View {
        ZStack {
            Theme.heroGradient
            Image(systemName: loading ? "photo" : icon)
                .font(.system(size: 22))
                .foregroundStyle(Theme.ember.opacity(0.9))
        }
    }
}
