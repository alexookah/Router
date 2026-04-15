import SwiftUI
import Router

struct DetailView: View {
    @Environment(Router<AppRoute>.self) var router
    let id: String

    var body: some View {
        List {
            Section("Detail \(id)") {
                Text("This is detail screen \(id)")
            }

            Section("Navigation") {
                Button("Push Another Detail (C)") {
                    router.push(route: .home(.detail("C")))
                }
                Button("Replace With Detail (D)") {
                    router.replaceLast(with: .home(.detail("D")))
                }
                Button("Pop") {
                    router.pop()
                }
                Button("Pop to Root") {
                    router.popToRoot()
                }
            }

            Section("Modal from Deep") {
                Button("Present Sheet (target: .deepest)") {
                    router.presentSheet(
                        route: .search(.results("from detail \(id)")),
                        options: .init(detents: [.medium, .large]),
                        target: .deepest
                    )
                }
            }
        }
        .navigationTitle("Detail \(id)")
    }
}
