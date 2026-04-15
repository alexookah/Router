import SwiftUI
import Router

enum AppTab: String, CaseIterable, Hashable {
    case home, search, profile
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    @State var homeRouter = AppRouter()
    @State var searchRouter = AppRouter()
    @State var profileRouter = AppRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                RoutingView(homeRouter) { router in
                    router.start(.home(.home))
                }
            }

            Tab("Search", systemImage: "magnifyingglass", value: AppTab.search) {
                RoutingView(searchRouter) { router in
                    router.start(.search(.search))
                }
            }

            Tab("Profile", systemImage: "person", value: AppTab.profile) {
                RoutingView(profileRouter) { router in
                    router.start(.profile(.profile))
                }
            }
        }
        .onDeepLink { [self] url in
            guard url.scheme == "routerdemo",
                  let host = url.host else { return }
            let path = url.pathComponents.dropFirst()

            switch host {
            case "home":
                selectedTab = .home
                if let id = path.first {
                    homeRouter.push(route: .home(.detail(id)))
                }
            case "search":
                selectedTab = .search
                if let query = path.first {
                    searchRouter.presentSheet(
                        route: .search(.results(query)),
                        options: .init(detents: [.medium, .large])
                    )
                }
            case "profile":
                selectedTab = .profile
                if path.first == "edit" {
                    profileRouter.present(route: .profile(.editProfile))
                }
            default:
                break
            }
        }
    }
}
