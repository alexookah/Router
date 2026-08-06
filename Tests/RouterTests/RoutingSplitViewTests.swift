import SwiftUI
import Testing
@testable import Router

@Suite("RoutingSplitView")
struct RoutingSplitViewTests {
    enum SidebarRoute: Routable {
        case root
        func destination() -> some View { Text("Sidebar") }
    }

    enum DetailRoute: Routable {
        case overview
        case item(Int)
        func destination() -> some View { Text("Detail") }
    }

    enum ModalRoute: Routable {
        case settings
        func destination() -> some View { Text("Settings") }
    }

    /// Generic inference: distinct Routable types per surface, optional
    /// bindings omitted, no screen-level modals (Never).
    @MainActor
    @Test func constructsWithDistinctRouteTypes() {
        let router = SplitRouter<SidebarRoute, DetailRoute, Never>()
        _ = RoutingSplitView(router) { sidebar in
            sidebar.start(.root)
        } detail: { detail in
            detail.start(.overview)
        }
        #expect(router.sidebar.isFullyAtRoot)
        #expect(router.detail.isFullyAtRoot)
    }

    /// Column routers stay independent: pushing/presenting on one never
    /// touches the other, and path conveniences forward correctly.
    @MainActor
    @Test func columnRoutersAreIndependent() {
        let router = SplitRouter<SidebarRoute, DetailRoute, Never>()

        router.pushDetail(.item(7))
        router.detail.presentSheet(route: .overview)

        #expect(router.detailPath == [.item(7)])
        #expect(router.detail.presentingSheet == .overview)
        #expect(router.sidebar.isFullyAtRoot)

        router.popAllToRoot()
        #expect(router.detailPath.isEmpty)
        #expect(router.detail.presentingSheet == nil)
    }

    /// Screen-level modals hosted by the split view via the modals router.
    @MainActor
    @Test func constructsWithModalsRouter() {
        let router = SplitRouter<SidebarRoute, DetailRoute, ModalRoute>()
        _ = RoutingSplitView(router) { sidebar in
            sidebar.start(.root)
        } detail: { detail in
            detail.start(.overview)
        }

        router.presentModal(.settings)
        #expect(router.modals.presentingSheet == .settings)
        #expect(router.sidebar.isFullyAtRoot)
        #expect(router.detail.isFullyAtRoot)

        router.dismissModal()
        #expect(router.modals.presentingSheet == nil)
    }

    /// Routes that own their navigation (e.g. a NavigationSplitView) opt out
    /// of the RoutingView wrapper via `providesOwnNavigation`.
    @MainActor
    @Test func providesOwnNavigationDefaultsAndOverrides() {
        #expect(!SidebarRoute.root.providesOwnNavigation)

        enum BareRoute: Routable {
            case fullScreenWorld
            var providesOwnNavigation: Bool { true }
            func destination() -> some View { Text("Bare") }
        }
        #expect(BareRoute.fullScreenWorld.providesOwnNavigation)
    }
}
