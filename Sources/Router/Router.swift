import SwiftUI

/// Not `final` so ``SplitRouter`` can subclass it; `public` (not `open`)
/// still prevents subclassing outside the package.
@MainActor
@Observable
public class Router<Destination: Routable> {

    // MARK: - Public State

    public var path: [Destination] = []

    /// Assigning starts a new presentation; `replace(with:)` swaps the
    /// current one's content while keeping its identity.
    public var presentingSheet: PresentedRoute<Destination>?

    /// Same semantics as ``presentingSheet``; `sheetOptions` is unused here.
    public var presentingFullScreenCover: PresentedRoute<Destination>?

    // MARK: - Private Hierarchy

    @ObservationIgnored
    private weak var parentRouter: Router<Destination>?

    /// The child router created for a sheet/fullScreenCover, paired with the
    /// route it was created for.
    @ObservationIgnored
    private var child: (router: Router<Destination>, destination: Destination)?

    // MARK: - Computed Properties

    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }

    /// Whether this router's presentation is being torn down — either directly
    /// (parent stopped presenting) or transitively (an ancestor is dismissing).
    public var isDismissing: Bool {
        guard let parentRouter else { return false }
        return !parentRouter.isPresenting || parentRouter.isDismissing
    }

    public var isRootRouter: Bool {
        parentRouter == nil
    }

    /// Root router, empty path, no active modals.
    public var isFullyAtRoot: Bool {
        isRootRouter && path.isEmpty && !isPresenting
    }

    public var hasChild: Bool {
        child != nil
    }

    // MARK: - Init

    public init(parentRouter: Router<Destination>? = nil) {
        self.parentRouter = parentRouter
    }

    // MARK: - View Handling

    /// Safe to call repeatedly with the same route (SwiftUI may re-render).
    public func start(_ route: Destination) -> Destination.ViewType {
        route.destination()
    }

    /// `.push` returns self; `.sheet`/`.fullScreenCover` reuses the child only
    /// when it already shows `target` (a re-render), otherwise creates a fresh one.
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

    /// The child router for a ``PresentedNavigation/split(sidebar:detail:)``
    /// presentation. Same reuse rule as ``routerFor(routeType:toShow:)``, but
    /// the child is a `SplitRouter` so it can drive a ``SplitRoutingView``.
    public func splitRouterFor(toShow target: Destination) -> SplitRouter<Destination> {
        if let child, child.destination == target,
           let split = child.router as? SplitRouter<Destination> {
            return split
        }
        let router = SplitRouter<Destination>(parentRouter: self)
        child = (router, target)
        return router
    }

    // MARK: - Navigation

    public func push(route: Destination, target: NavigationTarget = .current) {
        let router = targetRouter(for: target)
        router.path.append(route)
    }

    #if os(iOS)
    /// iOS only — macOS has no full-screen cover; use `presentSheet(...)`.
    ///
    /// Pass `navigation: .own` when the destination builds its own
    /// `NavigationStack` / `NavigationSplitView`.
    public func present(
        route: Destination,
        navigation: PresentedNavigation<Destination> = .stack(dismiss: .visible),
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingSheet = nil
        router.presentingFullScreenCover = PresentedRoute(route, navigation: navigation)
    }
    #endif

    /// Pass `navigation: .own` when the destination builds its own
    /// `NavigationStack` / `NavigationSplitView`.
    public func presentSheet(
        route: Destination,
        navigation: PresentedNavigation<Destination> = .stack(dismiss: .hidden),
        options: SheetPresentationOptions = .init(),
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingFullScreenCover = nil
        router.presentingSheet = PresentedRoute(
            route,
            navigation: navigation,
            sheetOptions: options
        )
    }

    public func pop(last count: Int = 1) {
        guard !path.isEmpty else { return }
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replaceStack(with routes: [Destination]) {
        path = routes
    }

    /// Replaces the last `count` visible destinations with `route` — the top
    /// of `path`, or the parent's presentation when `path` is empty.
    ///
    /// The replacement is in place: a same-depth path replace re-renders the
    /// screen, and a presented modal keeps its identity so only its view
    /// changes. For a dismiss-and-re-present, call `presentSheet`/`present`.
    public func replace(last count: Int = 1, with route: Destination) {
        if path.isEmpty {
            replaceParentPresentation(with: route)
        } else {
            path = Array(path.dropLast(min(count, path.count))) + [route]
        }
    }

    /// Swaps the route while keeping the presentation's id, so `sheet(item:)`
    /// replaces the view instead of dismissing and re-presenting.
    private func replaceParentPresentation(with route: Destination) {
        guard let parentRouter else { return }
        if let sheet = parentRouter.presentingSheet {
            parentRouter.presentingSheet = sheet.replacing(route)
        } else if let cover = parentRouter.presentingFullScreenCover {
            parentRouter.presentingFullScreenCover = cover.replacing(route)
        }
    }

    public func lastPathIs(_ route: Destination) -> Bool {
        path.last == route
    }

    // MARK: - Dismissal

    public func dismissChild() {
        presentingSheet = nil
        presentingFullScreenCover = nil
        child = nil
    }

    /// Called by `RoutingView` when the system dismisses a modal (e.g.
    /// swipe-down). Clears the child only if no new presentation is active.
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

    public func dismissAllFromRoot() {
        let root = rootRouter
        root.dismissChild()
        root.popToRoot()
    }

    // MARK: - Private Hierarchy Helpers

    private func targetRouter(for target: NavigationTarget) -> Router {
        switch target {
        case .current: nearestActiveRouter
        case .parent: parentRouter ?? self
        case .child: child?.router ?? self
        case .root: rootRouter
        case .deepest: deepestChildRouter ?? self
        }
    }

    /// Walks up the parent chain to the first router that isn't being dismissed.
    private var nearestActiveRouter: Router {
        guard isDismissing, let parentRouter else { return self }
        return parentRouter.nearestActiveRouter
    }

    private var deepestChildRouter: Router? {
        guard let router = child?.router else { return nil }
        return router.deepestChildRouter ?? router
    }

    private var rootRouter: Router {
        parentRouter?.rootRouter ?? self
    }
}
