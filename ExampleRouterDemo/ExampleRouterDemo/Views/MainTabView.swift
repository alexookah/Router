//
//  MainTabView.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

enum AppTab: String, CaseIterable, Hashable {
    case home, stacking, profile, split, deepLinks
}

struct MainTabView: View {
    @State private var selectedTab: AppTab = .home

    @State var homeRouter = AppRouter()
    @State var stackingRouter = AppRouter()
    @State var profileRouter = AppRouter()
    @State var deepLinksRouter = AppRouter()
    @State var splitRouter = SplitAppRouter(columnVisibility: .all)

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: AppTab.home) {
                RoutingView(homeRouter, root: .home(.home))
            }

            Tab("Stacking", systemImage: "square.stack", value: AppTab.stacking) {
                RoutingView(stackingRouter, root: .stacking(.stacking))
            }

            Tab("Profile", systemImage: "person", value: AppTab.profile) {
                RoutingView(profileRouter, root: .profile(.profile))
            }

            Tab("Split", systemImage: "sidebar.left", value: AppTab.split) {
                SplitDemoView(router: splitRouter)
            }

            Tab("Deep Links", systemImage: "link", value: AppTab.deepLinks) {
                RoutingView(deepLinksRouter, root: .deepLinks(.deepLinks))
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
        case "split":
            // routerdemo://split/article/7 → push in the detail column
            // routerdemo://split/folder/2  → drill the sidebar column
            selectedTab = .split
            splitRouter.popAllToRoot()
            if let kind = path.first, let id = path.dropFirst().first.flatMap({ Int($0) }) {
                navigateAfterTabSwitch {
                    switch kind {
                    case "article": splitRouter.push(route: .split(.article(id)))
                    case "folder": splitRouter.sidebarPath = [.split(.folder(id))]
                    default: break
                    }
                }
            }
        default:
            return false
        }
        return true
    }

    /// Delays navigation slightly to let the tab switch animation settle.
    @MainActor
    private func navigateAfterTabSwitch(_ action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(0.3))
            action()
        }
    }
}
