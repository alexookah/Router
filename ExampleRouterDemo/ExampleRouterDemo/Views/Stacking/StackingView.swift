//
//  StackingView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct StackingView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section {
                Text("Present sheets on top of sheets. Each layer presents the next one using target: .deepest.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section {
                Button("Present Layer 1 (Sheet)") {
                    router.presentSheet(
                        route: .stacking(.layer(1)),
                        options: .init(detents: [.medium, .large])
                    )
                }
            }
        }
        .navigationTitle("Stacking")
    }
}
