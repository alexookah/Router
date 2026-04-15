//
//  DetailView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct DetailView: View {
    @Environment(Router<AppRoute>.self) var router
    let id: String

    var body: some View {
        List {
            Section {
                Text("This is detail screen \(id)")
            }

            Section("Navigate") {
                Button("Push Detail C") {
                    router.push(route: .home(.detail("C")))
                }
                Button("Pop") {
                    router.pop()
                }
                Button("Pop to Root") {
                    router.popToRoot()
                }
            }
        }
        .navigationTitle("Detail \(id)")
    }
}
