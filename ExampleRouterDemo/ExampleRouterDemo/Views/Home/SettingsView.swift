//
//  SettingsView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct SettingsView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section("Settings") {
                Text("This is the settings screen, presented as a full-screen cover.")
                Text("Notice the dismiss button in the top-left corner.")
            }

            Section("Navigation Within Modal") {
                Button("Push Detail (inside full-screen cover)") {
                    router.push(route: .home(.detail("settings-inner")))
                }
            }

            Section("Dismiss") {
                Button("Dismiss Self") {
                    router.dismissSelf()
                }
            }
        }
        .navigationTitle("Settings")
    }
}
