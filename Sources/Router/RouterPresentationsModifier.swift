import SwiftUI

/// Hosts a router's sheet and full-screen-cover presentations on a view
/// without creating a `NavigationStack`.
///
/// Used internally by `RoutingView`, and exposed via
/// `View.routerPresentations(_:)` for containers that own their navigation
/// (a `NavigationSplitView`, `TabView`, or externally driven stack).
struct RouterPresentationsModifier<Destination: Routable>: ViewModifier {
    @Bindable var router: Router<Destination>

    func body(content: Content) -> some View {
        content
            .sheet(
                item: $router.presentingSheet,
                onDismiss: router.onPresentationDismissed
            ) { route in
                presentedContent(for: route, as: .sheet)
                    .ifLet(router.sheetPresentationOptions.detents) { view, detents in
                        view.presentationDetents(detents)
                    }
                    .presentationDragIndicator(router.sheetPresentationOptions.dragIndicator)
            }
            #if os(iOS)
            .fullScreenCover(
                item: $router.presentingFullScreenCover,
                onDismiss: router.onPresentationDismissed
            ) { route in
                presentedContent(for: route, as: .fullScreenCover)
            }
            #endif
    }

    /// The content hosted inside a sheet or cover: a `RoutingView` backed by
    /// a child router (enabling pushes and further presentation), or the bare
    /// destination when the route provides its own navigation container.
    @ViewBuilder
    private func presentedContent(for route: Destination, as routeType: NavigationType) -> some View {
        if route.providesOwnNavigation {
            route.destination()
        } else {
            RoutingView(router.routerFor(routeType: routeType, toShow: route)) { childRouter in
                childRouter.start(route)
            }
        }
    }
}

public extension View {
    /// Hosts a router's sheet and full-screen-cover presentations on this
    /// view, without introducing a `NavigationStack`.
    ///
    /// Use this when the presenting context owns its own navigation — a
    /// `NavigationSplitView`, a `TabView`, or a plain view — and you want
    /// modals driven by `router.presentSheet(...)` / `router.present(...)`:
    ///
    /// ```swift
    /// NavigationSplitView { sidebar } detail: { detail }
    ///     .routerPresentations(modalsRouter)
    /// ```
    ///
    /// Presented content runs inside its own `RoutingView` with a child
    /// router, so routes can push and present further; `RoutingView` uses
    /// this same modifier internally, so behavior is identical either way.
    func routerPresentations<Destination: Routable>(
        _ router: Router<Destination>
    ) -> some View {
        modifier(RouterPresentationsModifier(router: router))
    }
}
