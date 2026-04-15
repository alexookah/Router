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
            Section {
                Text("Presented as a full-screen cover with a dismiss button.")
            }

            Section("Navigate Inside Modal") {
                Button("Push Detail") {
                    router.push(route: .home(.detail("settings-inner")))
                }
            }
        }
        .navigationTitle("Settings")
    }
}
