import SwiftUI
import Router

struct SearchResultsView: View {
    @Environment(Router<AppRoute>.self) var router
    let query: String

    var body: some View {
        List {
            Section("Results for \"\(query)\"") {
                ForEach(1...5, id: \.self) { i in
                    Button("Result \(i) — Push Detail") {
                        router.push(route: .home(.detail("result-\(i)")))
                    }
                }
            }

            Section("Sheet Info") {
                Text("This view is presented as a sheet with .medium and .large detents.")
                Text("Try dragging to resize.")
            }

            Section("Actions") {
                Button("Dismiss") {
                    router.dismissSelf()
                }
                Button("Stack Another Sheet (target: .deepest)") {
                    router.presentSheet(
                        route: .profile(.profile),
                        target: .deepest
                    )
                }
            }
        }
        .navigationTitle("Results")
    }
}
