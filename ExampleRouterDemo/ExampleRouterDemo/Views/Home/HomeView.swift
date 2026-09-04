//
//  HomeView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct HomeView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section("Push") {
                Button("Detail A") {
                    router.push(route: .home(.detail("A")))
                }
                Button("Detail B") {
                    router.push(route: .home(.detail("B")))
                }
            }

            Section("Zoom transition") {
                Button {
                    router.push(route: .home(.detail("Zoomed")), transition: .zoom(sourceID: "push"))
                } label: {
                    Label("Push Detail, zooming from this row", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .zoomSource(id: "push")
                Button {
                    router.present(route: .home(.settings), transition: .zoom(sourceID: "cover"))
                } label: {
                    Label("Present Settings, zooming from this row", systemImage: "arrow.up.left.and.arrow.down.right")
                }
                .zoomSource(id: "cover")
            }

            Section("Present") {
                Button("Settings (Full Screen)") {
                    router.present(
                        route: .home(.settings),
                        dismiss: .init(
                            dismissButtonPosition: .right,
                            showDismissButtonOnPush: true
                        )
                    )
                }
            }

            Section("UIKit controllers, via ownsNavigation") {
                Button("Share sheet") {
                    router.presentSheet(
                        route: .home(.share(URL(string: "https://github.com/alexookah/Router")!)),
                        options: .init(detents: [.medium, .large])
                    )
                }
                Button("Photo picker") {
                    router.presentSheet(route: .home(.photoPicker))
                }
            }

            Section("Replace a sheet's content") {
                Button("Sheet with swap options") {
                    router.presentSheet(
                        route: .home(.swap(1)),
                        options: .init(detents: [.medium, .large])
                    )
                }
            }

            Section("Cross-Tab") {
                Button("Present Profile (via Root)") {
                    router.presentSheet(route: .profile(.profile), target: .root)
                }
            }
        }
        .navigationTitle("Home")
    }
}
