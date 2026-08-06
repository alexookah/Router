import SwiftUI

/// The routing counterpart of a `NavigationSplitView`, used with
/// ``SplitRoutingView`` — one object owning the navigation state of every
/// surface a split screen has: the sidebar stack, the detail stack, and the
/// screen-level modals.
///
/// `Router` is the single-surface primitive (one stack + one modal slot);
/// `SplitRouter` composes three of them behind one object:
///
/// ```swift
/// let appRouter = SplitRouter<SidebarRoute, DetailRoute, ModalRoute>()
///
/// appRouter.pushDetail(.article(article))
/// appRouter.presentModal(.settings)
/// ```
///
/// The three route types may be one shared enum (any route can go anywhere)
/// or distinct per surface (the compiler then rejects cross-surface
/// navigation). Screens without dedicated screen-level modals use `Never`
/// as the third parameter.
@MainActor
@Observable
public final class SplitRouter<
    SidebarDestination: Routable,
    DetailDestination: Routable,
    ModalDestination: Routable
> {

    /// Router for the sidebar column's stack and column-local modals.
    public let sidebar = Router<SidebarDestination>()

    /// Router for the detail column's stack and column-local modals.
    public let detail = Router<DetailDestination>()

    /// Router for modals that belong to the screen rather than a column —
    /// hosted above the split view by `SplitRoutingView`.
    public let modals = Router<ModalDestination>()

    public init() {}

    // MARK: - Path Conveniences

    /// The sidebar column's navigation stack.
    public var sidebarPath: [SidebarDestination] {
        get { sidebar.path }
        set { sidebar.path = newValue }
    }

    /// The detail column's navigation stack.
    public var detailPath: [DetailDestination] {
        get { detail.path }
        set { detail.path = newValue }
    }

    // MARK: - Navigation Conveniences

    /// Pushes a route onto the sidebar column's stack.
    public func pushSidebar(_ route: SidebarDestination) {
        sidebar.push(route: route)
    }

    /// Pushes a route onto the detail column's stack.
    public func pushDetail(_ route: DetailDestination) {
        detail.push(route: route)
    }

    /// Presents a screen-level modal above the split view.
    public func presentModal(
        _ route: ModalDestination,
        options: SheetPresentationOptions = .init(),
        dismissOptions: DismissButtonPresentationOptions = .sheetDismissOptions
    ) {
        modals.presentSheet(route: route, options: options, dismissOptions: dismissOptions)
    }

    /// Dismisses the currently presented screen-level modal, if any.
    public func dismissModal() {
        modals.dismissChild()
    }

    /// Pops every surface back to its root and dismisses any modal.
    public func popAllToRoot() {
        sidebar.popToRoot()
        detail.popToRoot()
        sidebar.dismissChild()
        detail.dismissChild()
        modals.dismissChild()
    }
}
