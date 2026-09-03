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
            .sheet(item: $router.presentingSheet, onDismiss: router.onPresentationDismissed) { item in
                presentedContent(for: item, as: .sheet)
                    .ifLet(item.sheetOptions.detents) { view, detents in
                        view.presentationDetents(detents)
                    }
                    .presentationDragIndicator(item.sheetOptions.dragIndicator)
            }
            #if os(iOS)
            .fullScreenCover(item: $router.presentingFullScreenCover, onDismiss: router.onPresentationDismissed) { item in
                presentedContent(for: item, as: .fullScreenCover)
            }
            #endif
    }

    @ViewBuilder
    private func presentedContent(
        for item: PresentedRoute<Destination>,
        as routeType: NavigationType
    ) -> some View {
        switch item.navigation {
        case .own:
            item.route.destination()
        case let .stack(dismiss):
            RoutingView(
                router.routerFor(routeType: routeType, toShow: item.route),
                root: item.route,
                dismissOptions: dismiss
            )
        }
    }
}

public extension View {
    /// Hosts a router's sheet and full-screen-cover presentations on this
    /// view, without introducing a `NavigationStack`.
    ///
    /// Use this when the presenting context owns its own navigation — a
    /// `NavigationSplitView`, a `TabView`, or a plain view. `RoutingView` uses
    /// the same modifier internally, so behavior is identical either way.
    func routerPresentations<Destination: Routable>(
        _ router: Router<Destination>
    ) -> some View {
        modifier(RouterPresentationsModifier(router: router))
    }
}
