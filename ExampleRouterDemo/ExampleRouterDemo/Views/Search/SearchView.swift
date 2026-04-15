//
//  SearchView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

struct SearchView: View {
    @Environment(Router<AppRoute>.self) var router
    @State private var query = ""

    var body: some View {
        List {
            Section("Search") {
                TextField("Search query", text: $query)
                Button("Search") {
                    guard !query.isEmpty else { return }
                    router.presentSheet(
                        route: .search(.results(query)),
                        options: .init(detents: [.medium, .large])
                    )
                }
            }

            Section("Quick Searches") {
                ForEach(["SwiftUI", "Router", "Navigation"], id: \.self) { term in
                    Button("Search \"\(term)\"") {
                        router.presentSheet(
                            route: .search(.results(term)),
                            options: .init(detents: [.medium, .large])
                        )
                    }
                }
            }
        }
        .navigationTitle("Search")
    }
}
