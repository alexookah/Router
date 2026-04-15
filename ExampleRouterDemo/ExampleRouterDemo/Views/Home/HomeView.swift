import SwiftUI
import Router

struct HomeView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        List {
            Section("Push Navigation") {
                Button("Push Detail A") {
                    router.push(route: .home(.detail("A")))
                }
                Button("Push Detail B") {
                    router.push(route: .home(.detail("B")))
                }
            }

            Section("Sheet Presentation") {
                Button("Present Search Results (Sheet with Detents)") {
                    router.presentSheet(
                        route: .search(.results("from home")),
                        options: .init(detents: [.medium, .large])
                    )
                }
            }

            Section("Full-Screen Cover") {
                Button("Present Settings (Full Screen)") {
                    router.present(
                        route: .home(.settings),
                        dismissOptions: .init(
                            showDismissButton: true,
                            dismissButtonPosition: .left,
                            showDismissButtonOnPush: true
                        )
                    )
                }
            }

            Section("Cross-Tab Routing") {
                Button("Present Profile (via Root)") {
                    router.presentSheet(
                        route: .profile(.profile),
                        target: .root
                    )
                }
            }

            Section("Stack Manipulation") {
                Button("Replace Stack with [Detail A, Detail B]") {
                    router.replaceNavigationStack(with: [
                        .home(.detail("A")),
                        .home(.detail("B"))
                    ])
                }
            }
        }
        .navigationTitle("Home")
    }
}
