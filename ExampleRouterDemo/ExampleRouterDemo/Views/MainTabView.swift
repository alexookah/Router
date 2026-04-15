//
//  MainTabView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

enum AppTab: String, CaseIterable, Hashable {
    case home, search, profile, deepLinks
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    @State var homeRouter = AppRouter()
    @State var searchRouter = AppRouter()
    @State var profileRouter = AppRouter()
    @State var deepLinksRouter = AppRouter()

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

            Tab("Deep Links", systemImage: "link", value: AppTab.deepLinks) {
                RoutingView(deepLinksRouter) { router in
                    router.start(.deepLinks(.deepLinks))
                }
            }
        }
        .onDeepLink { url in
            handleDeepLink(url)
        }
    }

    private func handleDeepLink(_ url: URL) -> Bool {
        guard url.scheme == "routerdemo",
              let host = url.host else { return false }
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
            return false
        }
        return true
    }
}
