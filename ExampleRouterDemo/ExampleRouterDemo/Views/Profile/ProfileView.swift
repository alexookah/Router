//
//  ProfileView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct ProfileView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section("Profile") {
                Text("User: Demo User")
                Text("Email: demo@example.com")
            }

            Section("Actions") {
                Button("Edit Profile (Full-Screen Cover)") {
                    router.present(
                        route: .profile(.editProfile),
                        dismissOptions: .init(
                            showDismissButton: true,
                            dismissButtonPosition: .right
                        )
                    )
                }
            }

            Section("Cross-Tab Demo") {
                Button("Present Home Detail (via Root)") {
                    router.presentSheet(
                        route: .home(.detail("from-profile")),
                        target: .root
                    )
                }
            }
        }
        .navigationTitle("Profile")
    }
}
