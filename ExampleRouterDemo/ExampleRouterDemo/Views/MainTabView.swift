//
//  MainTabView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

enum AppTab: String, CaseIterable, Hashable {
    case home, stacking, profile, deepLinks
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    @State var homeRouter = AppRouter()
    @State var stackingRouter = AppRouter()
    @State var profileRouter = AppRouter()
    @State var deepLinksRouter = AppRouter()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                RoutingView(homeRouter) { router in
                    router.start(.home(.home))
                }
            }

            Tab("Stacking", systemImage: "square.stack", value: AppTab.stacking) {
                RoutingView(stackingRouter) { router in
                    router.start(.stacking(.stacking))
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
            homeRouter.dismissChild()
            homeRouter.popToRoot()
            if let id = path.first {
                navigateAfterTabSwitch {
                    homeRouter.push(route: .home(.detail(id)))
                }
            }
        case "profile":
            selectedTab = .profile
            profileRouter.dismissChild()
            profileRouter.popToRoot()
            if path.first == "edit" {
                navigateAfterTabSwitch {
                    profileRouter.present(route: .profile(.editProfile))
                }
            }
        default:
            return false
        }
        return true
    }

    /// Delays navigation slightly to let the tab switch animation settle.
    private func navigateAfterTabSwitch(_ action: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}
