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

            Section("Present") {
                Button("Settings (Full Screen)") {
                    router.present(
                        route: .home(.settings),
                        dismissOptions: .init(
                            showDismissButton: true,
                            dismissButtonPosition: .right,
                            showDismissButtonOnPush: true
                        )
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
