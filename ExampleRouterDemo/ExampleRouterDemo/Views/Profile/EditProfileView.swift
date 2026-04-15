//
//  EditProfileView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct EditProfileView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section {
                Text("Full-screen cover with dismiss button on the right.")
            }

            Section {
                Button("Save & Dismiss") {
                    router.dismissSelf()
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
}
