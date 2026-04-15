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
            Section {
                Text("User: Demo User")
                Text("Email: demo@example.com")
            }

            Section {
                Button("Edit Profile (Full Screen)") {
                    router.present(
                        route: .profile(.editProfile),
                        dismissOptions: .init(dismissButtonPosition: .right)
                    )
                }
            }
        }
        .navigationTitle("Profile")
    }
}
