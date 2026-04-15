import SwiftUI

@MainActor
@Observable
public final class Router<Destination: Routable> {

    // MARK: - Public State

    public var path: [Destination] = []
    public var presentingSheet: Destination?
    public var sheetPresentationOptions: SheetPresentationOptions = .init()
    public var presentingFullScreenCover: Destination?
    public var dismissOptions: DismissButtonPresentationOptions = .init()

    // MARK: - Private Hierarchy

    @ObservationIgnored
    private weak var parentRouter: Router<Destination>?

    @ObservationIgnored
    private var childRouter: Router<Destination>?

    // MARK: - Computed Properties

    public var isPresenting: Bool {
        presentingSheet != nil || presentingFullScreenCover != nil
    }

    public var isRootRouter: Bool {
        parentRouter == nil
    }

    public var isFullyAtRoot: Bool {
        isRootRouter && path.isEmpty && !isPresenting
    }

    public var hasChild: Bool {
        childRouter != nil
    }

    public var showDismissButtonOnPush: Bool {
        !isRootRouter && dismissOptions.showDismissButton && dismissOptions.showDismissButtonOnPush
    }

    // MARK: - Init

    public init(parentRouter: Router<Destination>? = nil) {
        self.parentRouter = parentRouter
    }

    // MARK: - View Handling

    public func start(_ route: Destination) -> Destination.ViewType {
        route.destination()
    }

    @ViewBuilder
    public func view(for route: Destination) -> Destination.ViewType {
        route.destination()
    }

    public func routerFor(routeType: NavigationType) -> Router {
        switch routeType {
        case .push:
            return self
        case .sheet, .fullScreenCover:
            if let childRouter {
                return childRouter
            }
            let child = Router(parentRouter: self)
            childRouter = child
            return child
        }
    }


    // MARK: - Navigation

    public func push(route: Destination, target: NavigationTarget = .current) {
        let router = targetRouter(for: target)
        router.path.append(route)
    }

    public func present(
        route: Destination,
        dismissOptions: DismissButtonPresentationOptions = .fullScreenDismissOptions,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        let child = router.routerFor(routeType: .fullScreenCover())
        child.dismissOptions = dismissOptions
        router.presentingFullScreenCover = route
    }

    public func presentSheet(
        route: Destination,
        options: SheetPresentationOptions = .init(),
        dismissOptions: DismissButtonPresentationOptions = .sheetDismissOptions,
        target: NavigationTarget = .current
    ) {
        let router = targetRouter(for: target)
        let child = router.routerFor(routeType: .sheet())
        child.dismissOptions = dismissOptions
        router.sheetPresentationOptions = options
        router.presentingSheet = route
    }

    public func pop(last count: Int = 1) {
        guard !path.isEmpty else { return }
        let removeCount = min(count, path.count)
        path.removeLast(removeCount)
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func replaceNavigationStack(with routes: [Destination]) {
        path = routes
    }

    public func replaceLast(with route: Destination) {
        if path.isEmpty {
            path.append(route)
        } else {
            path[path.count - 1] = route
        }
    }

    public func lastPathIs(_ route: Destination) -> Bool {
        path.last == route
    }

    // MARK: - Dismissal

    public func dismissChild() {
        presentingSheet = nil
        presentingFullScreenCover = nil
        childRouter = nil
    }

    public func onPresentationDismissed() {
        if !isPresenting {
            childRouter = nil
        }
    }

    public func dismissSelf() {
        parentRouter?.dismissChild()
    }

    /// Dismisses this router's presentation and navigates on the parent router.
    ///
    /// After `dismissSelf()`, the child router is destroyed, so you can't call further
    /// navigation on it. This method captures the parent reference before dismissing.
    ///
    /// ```swift
    /// router.dismissAndRouteOnParent(route: .detail("1"), via: .push)
    /// router.dismissAndRouteOnParent(route: .settings, via: .sheet(options: .init(detents: [.medium])))
    /// router.dismissAndRouteOnParent(route: .profile, via: .fullScreenCover())
    /// ```
    public func dismissAndRouteOnParent(route: Destination, via type: NavigationType = .push) {
        guard let parentRouter else { return }
        parentRouter.dismissChild()
        switch type {
        case .push:
            parentRouter.push(route: route)
        case let .sheet(options, dismissOptions):
            parentRouter.presentSheet(route: route, options: options, dismissOptions: dismissOptions)
        case let .fullScreenCover(dismissOptions):
            parentRouter.present(route: route, dismissOptions: dismissOptions)
        }
    }

    public func dismissSelfOrPopToRoot() {
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
        case .current:
            return self
        case .parent:
            return parentRouter ?? self
        case .child:
            return childRouter ?? self
        case .root:
            return rootRouter
        case .deepest:
            return deepestChildRouter ?? self
        }
    }

    private var deepestChildRouter: Router? {
        guard let child = childRouter else { return nil }
        return child.deepestChildRouter ?? child
    }

    private var rootRouter: Router {
        var current = self
        while let parent = current.parentRouter {
            current = parent
        }
        return current
    }
}
