//
//  DeepLinksView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI

struct DeepLinksView: View {
    @Environment(\.openURL) private var openURL

    private let deepLinks: [(label: String, description: String, url: String)] = [
        ("Home", "Switches to Home tab", "routerdemo://home"),
        ("Home Detail", "Switches to Home tab, pushes Detail \"42\"", "routerdemo://home/42"),
        ("Search Results", "Switches to Search tab, opens results sheet for \"SwiftUI\"", "routerdemo://search/SwiftUI"),
        ("Edit Profile", "Switches to Profile tab, opens full-screen editor", "routerdemo://profile/edit"),
    ]

    var body: some View {
        List {
            Section {
                Text("Tap a link below to simulate a deep link. The same handler is used for real deep links from outside the app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Available Deep Links") {
                ForEach(deepLinks, id: \.url) { link in
                    Button {
                        guard let url = URL(string: link.url) else { return }
                        openURL(url)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(link.label)
                                .font(.headline)
                            Text(link.description)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(link.url)
                                .font(.caption2)
                                .monospaced()
                                .foregroundStyle(.blue)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }

            Section("How It Works") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("1. .onDeepLink on the TabView handles incoming URLs")
                    Text("2. The openURL environment is overridden to intercept routerdemo:// URLs")
                    Text("3. The handler switches tabs and navigates using the appropriate router")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Deep Links")
    }
}
