//
//  LayerView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct LayerView: View {
    @Environment(Router<AppRoute>.self) var router
    let depth: Int

    var body: some View {
        List {
            Section {
                Text("Sheet layer \(depth)")
                    .font(.title2.bold())
            }

            Section {
                Button("Present Layer \(depth + 1)") {
                    router.presentSheet(
                        route: .stacking(.layer(depth + 1)),
                        options: .init(detents: [.medium, .large]),
                        target: .deepest
                    )
                }
            }

            Section {
                Button("Dismiss This Layer") {
                    router.dismiss()
                }
                Button("Dismiss All From Root", role: .destructive) {
                    router.dismissAllFromRoot()
                }
            }
        }
        .navigationTitle("Layer \(depth)")
    }
}
