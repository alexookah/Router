import SwiftUI

@MainActor
@Observable
public final class Router<Destination: Routable> {

    // MARK: - Public State

    /// The navigation stack used to programmatically control push navigation.
    public var path: [Destination] = []

    /// The route currently presented as a sheet, if any.
    public var presentingSheet: Destination?

    /// Options applied to the active sheet presentation.
    public var sheetPresentationOptions: SheetPresentationOptions = .init()

    /// The route currently presented as a full-screen cover, if any.
    public var presentingFullScreenCover: Destination?

    /// Dismiss configuration for the modal this router is presenting.
    public var presentationDismissOptions: DismissButtonPresentationOptions?

    /// Dismiss configuration for this router's own content, set by its presenter.
    public var dismissOptions: DismissButtonPresentationOptions {
        parentRouter?.presentationDismissOptions ?? .hidden
    }

    // MARK: - Private Hierarchy

    /// Reference to the parent router so this router can be dismissed.
    @ObservationIgnored
    private weak var parentRouter: Router<Destination>?

    /// The child router created for a sheet/fullScreenCover, paired with the
    /// route it was created for.
    @ObservationIgnored
    private var child: (router: Router<Destination>, destination: Destination)?

    // MARK: - Computed Properties

    /// Whether a sheet or full-screen cover is currently presented.
    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }

    /// Whether this router's presentation is being torn down — either directly
    /// (parent stopped presenting) or transitively (an ancestor is dismissing).
    public var isDismissing: Bool {
        guard let parentRouter else { return false }
        return !parentRouter.isPresenting || parentRouter.isDismissing
    }

    /// Whether this is the root router (has no parent).
    public var isRootRouter: Bool {
        parentRouter == nil
    }

    /// Whether this is the root router with an empty path and no active modals.
    public var isFullyAtRoot: Bool {
        isRootRouter && path.isEmpty && !isPresenting
    }

    /// Whether this router has an active child router.
    public var hasChild: Bool {
        child != nil
    }

    /// Whether pushed views should show a dismiss button.
    public var showDismissButtonOnPush: Bool {
        dismissOptions.showDismissButton && dismissOptions.showDismissButtonOnPush
    }

    // MARK: - Init

    /// Creates a new router with an optional parent.
    public init(parentRouter: Router<Destination>? = nil) {
        self.parentRouter = parentRouter
    }

    // MARK: - View Handling

    /// Returns the initial view for a `RoutingView`.
    /// Safe to call multiple times with the same route (SwiftUI may re-render).
    public func start(_ route: Destination) -> Destination.ViewType {
        route.destination()
    }

    /// Returns the appropriate router for a navigation type.
    /// `.push` returns self; `.sheet`/`.fullScreenCover` reuses the child only when
    /// it already shows `target` (a re-render), otherwise creates a fresh one.
    public func routerFor(routeType: NavigationType, toShow target: Destination) -> Router {
        switch routeType {
        case .push:
            return self
        case .sheet, .fullScreenCover:
            if let child, child.destination == target {
                return child.router
            }
            let router = Router(parentRouter: self)
            child = (router, target)
            return router
        }
    }

    // MARK: - Navigation

    /// Pushes a route onto the navigation stack of the targeted router.
    public func push(route: Destination, target: NavigationTarget = .current) {
        let router = targetRouter(for: target)
        router.path.append(route)
    }

    #if os(iOS)
    /// Presents a route as a full-screen cover. iOS only —
    /// macOS has no full-screen cover equivalent; use `presentSheet(...)` instead.
    public func present(
        route: Destination,
        dismissOptions: DismissButtonPresentationOptions = .visible,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingSheet = nil
        router.presentationDismissOptions = dismissOptions
        router.presentingFullScreenCover = route
    }
    #endif

    /// Presents a route as a sheet with optional detents and dismiss button.
    public func presentSheet(
        route: Destination,
        options: SheetPresentationOptions = .init(),
        dismissOptions: DismissButtonPresentationOptions = .hidden,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingFullScreenCover = nil
        router.presentationDismissOptions = dismissOptions
        router.sheetPresentationOptions = options
        router.presentingSheet = route
    }

    /// Removes one or more views from the navigation stack.
    /// - Parameter count: The number of views to remove. Defaults to 1.
    public func pop(last count: Int = 1) {
        guard !path.isEmpty else { return }
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }

    /// Removes all views from the navigation stack.
    public func popToRoot() {
        path.removeAll()
    }

    /// Replaces the entire navigation stack with a new set of routes.
    public func replaceStack(with routes: [Destination]) {
        path = routes
    }

    /// Replaces the last `count` visible destinations with `route` — the top of
    /// `path`, or the parent's presentation when `path` is empty. Substitution
    /// shouldn't read as a transition, so this doesn't animate unless asked.
    public func replace(last count: Int = 1, with route: Destination, animated: Bool = false) {
        if animated {
            performReplace(last: count, with: route)
        } else {
            withoutAnimation { performReplace(last: count, with: route) }
        }
    }

    private func performReplace(last count: Int, with route: Destination) {
        guard !path.isEmpty else {
            replaceParentPresentation(with: route)
            return
        }
        path = Array(path.dropLast(min(count, path.count))) + [route]
    }

    private func replaceParentPresentation(with route: Destination) {
        guard let parentRouter else { return }
        if parentRouter.presentingSheet != nil {
            parentRouter.presentSheet(
                route: route,
                options: parentRouter.sheetPresentationOptions,
                dismissOptions: dismissOptions
            )
        } else if parentRouter.presentingFullScreenCover != nil {
            #if os(iOS)
            parentRouter.present(route: route, dismissOptions: dismissOptions)
            #endif
        }
    }

    /// Returns `true` if the last route in the stack matches the given route.
    public func lastPathIs(_ route: Destination) -> Bool {
        path.last == route
    }

    // MARK: - Dismissal

    /// Dismisses the current modal and clears the child router.
    public func dismissChild() {
        presentingSheet = nil
        presentingFullScreenCover = nil
        child = nil
    }

    /// Called by `RoutingView` when a modal is dismissed by the system (e.g. swipe-down).
    /// Clears the child router only if no new presentation is active.
    public func onPresentationDismissed() {
        if !isPresenting {
            child = nil
        }
    }

    /// Asks the parent router to dismiss this router.
    public func dismiss() {
        parentRouter?.dismissChild()
    }

    /// Dismisses the parent's modal if active, otherwise pops to root.
    public func dismissOrPopToRoot() {
        if let parentRouter, parentRouter.isPresenting {
            parentRouter.dismissChild()
        } else if !path.isEmpty {
            popToRoot()
        }
    }

    /// Dismisses the entire hierarchy from the root router.
    public func dismissAllFromRoot() {
        let root = rootRouter
        root.dismissChild()
        root.popToRoot()
    }

    // MARK: - Private Hierarchy Helpers

    /// Resolves the appropriate router for a given target.
    private func targetRouter(for target: NavigationTarget) -> Router {
        switch target {
        case .current: nearestActiveRouter
        case .parent: parentRouter ?? self
        case .child: child?.router ?? self
        case .root: rootRouter
        case .deepest: deepestChildRouter ?? self
        }
    }

    /// Walks up the parent chain to find the first router that isn't being dismissed.
    private var nearestActiveRouter: Router {
        guard isDismissing, let parentRouter else { return self }
        return parentRouter.nearestActiveRouter
    }

    /// The deepest (leaf) child router in the hierarchy, if any.
    private var deepestChildRouter: Router? {
        guard let router = child?.router else { return nil }
        return router.deepestChildRouter ?? router
    }

    /// The top-most parent router in the hierarchy.
    private var rootRouter: Router {
        parentRouter?.rootRouter ?? self
    }
}
