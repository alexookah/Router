import SwiftUI

/// Not `final` so ``SplitRouter`` can subclass it; `public` (not `open`)
/// still prevents subclassing outside the package.
@MainActor
@Observable
public class Router<Destination: Routable> {

    // MARK: - Public State

    public var path: [Destination] = [] {
        didSet { pushTransitions = pushTransitions.filter { path.contains($0.key) } }
    }

    /// Transitions requested by `push(route:transition:)`, kept while the route
    /// is on the path. Keyed by route value: equal routes on the path share one.
    public private(set) var pushTransitions: [Destination: PresentationTransition] = [:]

    /// Assigning starts a new presentation; `replace(with:)` swaps the
    /// current one's content while keeping its identity.
    public var presentingSheet: PresentedRoute<Destination>?

    /// Same semantics as ``presentingSheet``; `sheetOptions` is unused here.
    /// iOS only in effect: the property exists on macOS, but nothing hosts a
    /// full-screen cover there — setting it directly is a silent no-op.
    public var presentingFullScreenCover: PresentedRoute<Destination>?

    /// The route this router's stack was started with, recorded by
    /// ``start(_:)``. Follows the latest value, so a conditional root
    /// (`hasFolders ? .folders : .empty`) stays current.
    public private(set) var rootDestination: Destination?

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

    /// False for the router of a bare presentation: it hosts sheets and covers
    /// but no stack, so a `push` on it shows nothing.
    public private(set) var hasNavigationStack = true

    /// The sheet or cover this router is showing, if any.
    public var presented: PresentedRoute<Destination>? {
        presentingSheet ?? presentingFullScreenCover
    }

    /// The furthest child in the hierarchy — what `NavigationTarget.deepest` resolves to.
    public var deepestRouter: Router {
        deepestChildRouter ?? self
    }

    /// The visible destination: the top of `path`, else the root.
    public var currentDestination: Destination? {
        path.last ?? rootDestination
    }

    /// What a `pop()` would reveal: beneath the top of `path`, else the root.
    public var previousDestination: Destination? {
        path.count > 1 ? path[path.count - 2] : rootDestination
    }

    public func currentDestinationIs(_ route: Destination) -> Bool {
        currentDestination == route
    }

    // MARK: - Init

    public init(parentRouter: Router<Destination>? = nil) {
        self.parentRouter = parentRouter
    }

    // MARK: - View Handling

    /// Records `route` as the root and returns its view. Safe to call
    /// repeatedly (SwiftUI re-renders); only a changed route is written.
    public func start(_ route: Destination) -> Destination.ViewType {
        if rootDestination != route {
            rootDestination = route
        }
        return route.destination()
    }

    /// `.push` returns self; `.sheet`/`.fullScreenCover` reuses the child only
    /// when it already shows `target` (a re-render), otherwise creates a fresh one.
    /// `hostsNavigationStack` is false for a bare presentation's child.
    public func routerFor(
        routeType: NavigationType,
        toShow target: Destination,
        hostsNavigationStack: Bool = true
    ) -> Router {
        switch routeType {
        case .push:
            return self
        case .sheet, .fullScreenCover:
            if let child, child.destination == target {
                return child.router
            }
            let router = Router(parentRouter: self)
            router.hasNavigationStack = hostsNavigationStack
            child = (router, target)
            return router
        }
    }

    // MARK: - Navigation

    /// `transition` animates the pushed screen, e.g. `.zoom` from a `zoomSource`.
    /// On a router without a stack (a bare presentation), presents a sheet
    /// instead, since there is nothing to push onto.
    public func push(
        route: Destination,
        transition: PresentationTransition? = nil,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        if router.hasNavigationStack {
            if let transition { router.pushTransitions[route] = transition }
            router.path.append(route)
        } else {
            router.presentSheet(route: route, transition: transition)
        }
    }

    #if os(iOS)
    /// iOS only — macOS has no full-screen cover; use `presentSheet(...)`.
    ///
    /// `dismiss` is the cover's button, leading by default; `nil` for none.
    public func present(
        route: Destination,
        dismiss: DismissButtonPresentationOptions? = .visible,
        transition: PresentationTransition? = nil,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingSheet = nil
        router.presentingFullScreenCover = PresentedRoute(route, dismiss: dismiss, transition: transition)
    }
    #endif

    /// `dismiss` is the sheet's button, none by default.
    public func presentSheet(
        route: Destination,
        dismiss: DismissButtonPresentationOptions? = nil,
        options: SheetPresentationOptions = .init(),
        transition: PresentationTransition? = nil,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        router.presentingFullScreenCover = nil
        router.presentingSheet = PresentedRoute(route, dismiss: dismiss, sheetOptions: options, transition: transition)
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
    ///
    /// `count` is clamped to the pushed path — a replace never crosses into
    /// the parent's presentation; only an empty path delegates upward,
    /// where "replace what's visible" has a single possible meaning.
    public func replace(last count: Int = 1, with route: Destination) {
        if path.isEmpty {
            parentRouter?.replacePresented(with: route)
        } else {
            path = Array(path.dropLast(min(count, path.count))) + [route]
        }
    }

    /// Swaps the content of the presentation *this* router is showing, keeping
    /// its identity so the modal stays on screen rather than being dismissed
    /// and re-presented.
    ///
    /// The modal survives, its *stack* does not: the new route gets a fresh
    /// child router, so anything pushed inside the old content is gone.
    ///
    /// Use this from the presenting side; ``replace(last:with:)`` is the same
    /// swap seen from inside the modal, where the parent owns the presentation.
    public func replacePresented(with route: Destination) {
        if let sheet = presentingSheet {
            presentingSheet = sheet.replacing(route)
        } else if let cover = presentingFullScreenCover {
            presentingFullScreenCover = cover.replacing(route)
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
        case .deepest: deepestRouter
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
