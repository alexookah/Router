//
//  ReaderView.swift
//  ExampleRouterDemo
//

import SwiftUI
import Router

/// A pushed screen whose route hides the tab bar while it is on top.
struct ReaderView: View {
    @Environment(AppRouter.self) private var router

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Reader")
                    .font(.largeTitle.bold())
                Text("This route declares `hidesTabBar`, so the tab bar slides away while it is on top of the stack and comes back on pop.")
                Button("Push another reader") {
                    router.push(route: .home(.reader))
                }
                Button("Pop") {
                    router.pop()
                }
            }
            .padding()
        }
        .navigationTitle("Reader")
        .navigationBarTitleDisplayMode(.inline)
    }
}
