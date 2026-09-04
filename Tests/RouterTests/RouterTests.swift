import SwiftUI
import Testing
@testable import Router

// MARK: - Test Route

enum TestRoute: Routable {
    case home
    case detail(String)
    case settings
    case profile
    case share

    func destination() -> some View {
        switch self {
        case .home:
            Text("Home")
        case .detail(let id):
            Text("Detail: \(id)")
        case .settings:
            Text("Settings")
        case .profile:
            Text("Profile")
        case .share:
            Text("Share")
        }
    }

    var ownsNavigation: Bool { self == .share }
}

// MARK: - Initialization

@Suite("Initialization")
struct InitializationTests {
    @MainActor
    @Test func emptyState() {
        let router = Router<TestRoute>()
        #expect(router.path.isEmpty)
        #expect(router.presentingSheet == nil)
        #expect(router.presentingFullScreenCover == nil)
        #expect(!router.isPresenting)
    }

    @MainActor
    @Test func rootRouterStatus() {
        let router = Router<TestRoute>()
        #expect(router.isRootRouter)
        #expect(router.isFullyAtRoot)
    }

    @MainActor
    @Test func childRouterIsNotRoot() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        #expect(!child.isRootRouter)
    }
}

// MARK: - Push Navigation

@Suite("Push Navigation")
struct PushNavigationTests {
    @MainActor
    @Test func singlePush() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        #expect(router.path == [.home])
    }

    @MainActor
    @Test func multiplePushes() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.push(route: .profile)
        #expect(router.path == [.home, .settings, .profile])
    }
}

// MARK: - Pop Navigation

@Suite("Pop Navigation")
struct PopNavigationTests {
    @MainActor
    @Test func singlePop() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.pop()
        #expect(router.path == [.home])
    }

    @MainActor
    @Test func popMultiple() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.push(route: .profile)
        router.pop(last: 2)
        #expect(router.path == [.home])
    }

    @MainActor
    @Test func popMoreThanAvailable() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.pop(last: 10)
        #expect(router.path.isEmpty)
    }

    @MainActor
    @Test func popEmptyPath() {
        let router = Router<TestRoute>()
        router.pop()
        #expect(router.path.isEmpty)
    }

    @MainActor
    @Test func popToRoot() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.push(route: .profile)
        router.popToRoot()
        #expect(router.path.isEmpty)
    }
}

// MARK: - Stack Manipulation

@Suite("Stack Manipulation")
struct StackManipulationTests {
    @MainActor
    @Test func replaceStack() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.replaceStack(with: [.settings, .profile])
        #expect(router.path == [.settings, .profile])
    }

    @MainActor
    @Test func replaceTopOfStack() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.replace(with: .profile)
        #expect(router.path == [.home, .profile])
    }

    @MainActor
    @Test func replaceSeveral() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.push(route: .detail("1"))
        router.replace(last: 2, with: .profile)
        #expect(router.path == [.home, .profile])
    }

    @MainActor
    @Test func replaceMoreThanAvailable() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.replace(last: 5, with: .profile)
        #expect(router.path == [.profile])
    }

    @MainActor
    @Test func replaceOnEmptyRootIsNoOp() {
        let router = Router<TestRoute>()
        router.replace(with: .profile)
        #expect(router.path.isEmpty)
    }

    @MainActor
    @Test func replaceAtRootSwapsParentPresentation() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet, toShow: .settings)

        child.replace(with: .profile)

        #expect(parent.presentingSheet?.route == .profile)
        let replacement = parent.routerFor(routeType: .sheet, toShow: .profile)
        #expect(replacement !== child)
    }

    @MainActor
    @Test func lastPathIs() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        #expect(router.lastPathIs(.settings))
        #expect(!router.lastPathIs(.home))
    }

    @MainActor
    @Test func lastPathIsOnEmpty() {
        let router = Router<TestRoute>()
        #expect(!router.lastPathIs(.home))
    }
}

// MARK: - Sheet Presentation

@Suite("Sheet Presentation")
struct SheetPresentationTests {
    @MainActor
    @Test func presentSheet() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        #expect(router.presentingSheet?.route == .settings)
        #expect(router.isPresenting)
        #expect(!router.hasChild)
    }

    @MainActor
    @Test func presentSheetStoresDismissOptions() {
        let router = Router<TestRoute>()
        router.presentSheet(
            route: .settings,
            dismiss: .init(dismissButtonPosition: .right)
        )
        #expect(router.presentingSheet?.navigation.dismissOptions != nil)
        #expect(router.presentingSheet?.navigation.dismissOptions?.dismissButtonPosition == .right)
    }

    @MainActor
    @Test func presentSheetWithOptions() {
        let router = Router<TestRoute>()
        let options = SheetPresentationOptions(detents: [.medium], dragIndicator: .hidden, isInteractiveDismissDisabled: true)
        router.presentSheet(route: .settings, options: options)
        #expect(router.presentingSheet?.sheetOptions == options)
        #expect(router.presentingSheet?.sheetOptions.isInteractiveDismissDisabled == true)
    }
}

// MARK: - Full Screen Cover

#if os(iOS)
@Suite("Full Screen Cover")
struct FullScreenCoverTests {
    @MainActor
    @Test func presentFullScreenCover() {
        let router = Router<TestRoute>()
        router.present(route: .profile)
        #expect(router.presentingFullScreenCover?.route == .profile)
        #expect(router.isPresenting)
    }
}
#endif

// MARK: - Dismissal

@Suite("Dismissal")
struct DismissalTests {
    @MainActor
    @Test func dismissChild() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        _ = router.routerFor(routeType: .sheet, toShow: .settings)
        #expect(router.hasChild)
        router.dismissChild()
        #expect(router.presentingSheet == nil)
        #expect(router.presentingFullScreenCover == nil)
        #expect(!router.hasChild)
    }

    @MainActor
    @Test func dismiss() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet, toShow: .settings)
        child.dismiss()
        #expect(parent.presentingSheet == nil)
        #expect(!parent.hasChild)
    }

    @MainActor
    @Test func dismissOrPopToRootDismissesPresentedChild() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet, toShow: .settings)
        child.dismissOrPopToRoot()
        #expect(parent.presentingSheet == nil)
    }

    @MainActor
    @Test func dismissOrPopToRootPopsWhenNotPresented() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.dismissOrPopToRoot()
        #expect(router.path.isEmpty)
    }

    @MainActor
    @Test func dismissAllFromRoot() {
        let root = Router<TestRoute>()
        root.push(route: .home)
        root.push(route: .settings)
        root.presentSheet(route: .profile)
        let child = root.routerFor(routeType: .sheet, toShow: .profile)
        child.push(route: .detail("1"))
        child.dismissAllFromRoot()
        #expect(root.path.isEmpty)
        #expect(root.presentingSheet == nil)
        #expect(!root.hasChild)
    }
}

// MARK: - Child Router Management

@Suite("Child Router Management")
struct ChildRouterTests {
    @MainActor
    @Test func routerForPushReturnsSelf() {
        let router = Router<TestRoute>()
        let result = router.routerFor(routeType: .push, toShow: .home)
        #expect(result === router)
    }

    @MainActor
    @Test func routerForSheetCreatesChild() {
        let router = Router<TestRoute>()
        let child = router.routerFor(routeType: .sheet, toShow: .settings)
        #expect(child !== router)
        #expect(router.hasChild)
        #expect(!child.isRootRouter)
    }

    @MainActor
    @Test func routerForSheetReusesChildForSameDestination() {
        let router = Router<TestRoute>()
        let child1 = router.routerFor(routeType: .sheet, toShow: .settings)
        let child2 = router.routerFor(routeType: .sheet, toShow: .settings)
        #expect(child1 === child2)
    }

    @MainActor
    @Test func routerForSheetRebuildsChildForDifferentDestination() {
        let router = Router<TestRoute>()
        let first = router.routerFor(routeType: .sheet, toShow: .settings)
        first.push(route: .detail("stale"))

        let second = router.routerFor(routeType: .sheet, toShow: .profile)
        #expect(second !== first)
        #expect(second.path.isEmpty)
    }

    @MainActor
    @Test func routerForFullScreenCoverCreatesChild() {
        let router = Router<TestRoute>()
        let child = router.routerFor(routeType: .fullScreenCover, toShow: .profile)
        #expect(child !== router)
        #expect(router.hasChild)
    }
}

// MARK: - onPresentationDismissed

@Suite("onPresentationDismissed")
struct OnPresentationDismissedTests {
    @MainActor
    @Test func clearsChildWhenNotPresenting() {
        let router = Router<TestRoute>()
        _ = router.routerFor(routeType: .sheet, toShow: .settings)
        #expect(router.hasChild)
        // Not presenting anything, so child should be cleared
        router.onPresentationDismissed()
        #expect(!router.hasChild)
    }

    @MainActor
    @Test func keepsChildWhenStillPresenting() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        _ = router.routerFor(routeType: .sheet, toShow: .settings)
        #expect(router.hasChild)
        // Still presenting, so child should remain
        router.onPresentationDismissed()
        #expect(router.hasChild)
    }
}

// MARK: - NavigationTarget

@Suite("NavigationTarget")
struct NavigationTargetTests {
    @MainActor
    @Test func pushWithRootTarget() {
        let root = Router<TestRoute>()
        root.presentSheet(route: .settings)
        let child = root.routerFor(routeType: .sheet, toShow: .settings)
        child.push(route: .home, target: .root)
        #expect(root.path == [.home])
        #expect(child.path.isEmpty)
    }

    @MainActor
    @Test func pushWithParentTarget() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        child.push(route: .settings, target: .parent)
        #expect(parent.path == [.settings])
        #expect(child.path.isEmpty)
    }

    @MainActor
    @Test func pushWithDeepestTarget() {
        let root = Router<TestRoute>()
        root.presentSheet(route: .settings)
        let child = root.routerFor(routeType: .sheet, toShow: .settings)
        root.push(route: .home, target: .deepest)
        #expect(child.path == [.home])
        #expect(root.path.isEmpty)
    }

    @MainActor
    @Test func pushWithDeepestTargetWalksWholeChain() {
        let root = Router<TestRoute>()
        root.presentSheet(route: .settings)
        let child = root.routerFor(routeType: .sheet, toShow: .settings)
        child.presentSheet(route: .profile)
        let grandchild = child.routerFor(routeType: .sheet, toShow: .profile)

        root.push(route: .home, target: .deepest)

        #expect(grandchild.path == [.home])
        #expect(child.path.isEmpty)
        #expect(root.path.isEmpty)
    }

    @MainActor
    @Test func pushWithDeepestTargetNoChild() {
        let router = Router<TestRoute>()
        router.push(route: .home, target: .deepest)
        #expect(router.path == [.home])
    }
}

// MARK: - Dismissing hierarchy

/// `.current` resolves through `nearestActiveRouter`, which must skip routers
/// whose presentation is being torn down.
@Suite("Dismissing Hierarchy")
struct DismissingHierarchyTests {
    @MainActor
    @Test func childOfNonPresentingParentIsDismissing() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        #expect(child.isDismissing)
    }

    @MainActor
    @Test func childOfPresentingParentIsNotDismissing() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet, toShow: .settings)
        #expect(!child.isDismissing)
    }

    /// A dismissing router hands its navigation to the parent instead of
    /// pushing onto a stack that is going away.
    @MainActor
    @Test func currentTargetSkipsDismissingRouter() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)

        child.push(route: .home)

        #expect(parent.path == [.home])
        #expect(child.path.isEmpty)
    }

    /// The condition is re-tested at every hop, so a whole dismissing chain
    /// resolves to the first router that isn't.
    @MainActor
    @Test func currentTargetWalksWholeDismissingChain() {
        let root = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: root)
        let grandchild = Router<TestRoute>(parentRouter: child)
        #expect(child.isDismissing)
        #expect(grandchild.isDismissing)

        grandchild.push(route: .home)

        #expect(root.path == [.home])
        #expect(child.path.isEmpty)
        #expect(grandchild.path.isEmpty)
    }

    /// An active router keeps its own navigation.
    @MainActor
    @Test func currentTargetStaysOnActiveRouter() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet, toShow: .settings)

        child.push(route: .home)

        #expect(child.path == [.home])
        #expect(parent.path.isEmpty)
    }
}

// MARK: - isFullyAtRoot

@Suite("isFullyAtRoot")
struct IsFullyAtRootTests {
    @MainActor
    @Test func trueWhenRootEmptyNotPresenting() {
        let router = Router<TestRoute>()
        #expect(router.isFullyAtRoot)
    }

    @MainActor
    @Test func falseWhenHasPath() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        #expect(!router.isFullyAtRoot)
    }

    @MainActor
    @Test func falseWhenPresenting() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        #expect(!router.isFullyAtRoot)
    }

    @MainActor
    @Test func falseWhenNotRoot() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        #expect(!child.isFullyAtRoot)
    }
}

// MARK: - showDismissButtonOnPush

@Suite("Presentation dismiss options")
struct PresentationDismissOptionsTests {
    /// The presentation carries its dismiss configuration; `RoutingView`
    /// receives it from the presenting modifier, not from the router.
    @MainActor
    @Test func presentingStoresDismissOptions() {
        let router = Router<TestRoute>()
        router.presentSheet(
            route: .settings,
            dismiss: .init(showDismissButtonOnPush: true)
        )
        #expect(router.presentingSheet?.navigation.dismissOptions != nil)
        #expect(router.presentingSheet?.navigation.dismissOptions?.showDismissButtonOnPush == true)
    }

    /// "No button" has one spelling: a `nil` in the presentation. `.own`
    /// carries no options at all, and a stack without a button carries `nil`,
    /// so a hidden button with on-push settings is unrepresentable.
    @MainActor
    @Test func ownNavigationHasNoDismissOptions() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        #expect(router.presentingSheet?.navigation == .stack(dismiss: nil))
        #expect(router.presentingSheet?.navigation.dismissOptions == nil)

        router.presentSheet(route: .share, dismiss: .visible)
        #expect(router.presentingSheet?.navigation == .own)
        #expect(router.presentingSheet?.navigation.dismissOptions == nil, "a route that owns its navigation has no bar for a button")
    }


    #if os(iOS)
    @MainActor
    @Test func coversDefaultToAVisibleDismissButton() {
        let router = Router<TestRoute>()
        router.present(route: .settings)
        #expect(router.presentingFullScreenCover?.navigation.dismissOptions == .visible)
    }
    #endif
}

@Suite("SplitRouter")
struct SplitRouterTests {
    @MainActor
    @Test func surfacesStartEmpty() {
        let router = SplitRouter<TestRoute>()
        #expect(router.isFullyAtRoot)
        #expect(router.sidebar.isFullyAtRoot)
    }

    @MainActor
    @Test func splitRoutingViewConstructs() {
        let router = SplitRouter<TestRoute>()
        _ = SplitRoutingView(router, sidebar: .home, detail: .profile)
        #expect(router.isFullyAtRoot)
    }

    /// Defaults mirror SwiftUI's own. Note a bound `.automatic` starts the
    /// sidebar hidden on iPad — apps wanting both columns set `.all`.
    @MainActor
    @Test func layoutDefaults() {
        let router = SplitRouter<TestRoute>()
        #expect(router.preferredCompactColumn == .sidebar)
        #expect(router.columnVisibility == .automatic)
        #expect(!router.isCollapsed)
    }

    /// The split router *is* the detail column, so `detail` is an alias for it.
    @MainActor
    @Test func detailIsTheRouterItself() {
        let router = SplitRouter<TestRoute>()
        #expect(router.detail === router)

        router.push(route: .profile)
        #expect(router.detail.path == [.profile])

        router.detail.push(route: .settings)
        #expect(router.path == [.profile, .settings])
    }

    @MainActor
    @Test func columnsAreIndependent() {
        let router = SplitRouter<TestRoute>()
        router.sidebarPath.append(.detail("folder"))
        router.push(route: .profile)

        #expect(router.sidebarPath == [.detail("folder")])
        #expect(router.path == [.profile])
    }

    /// Modals over the screen are presented on the split router; the sidebar
    /// column keeps its own slot.
    @MainActor
    @Test func screenModalLeavesTheSidebarAlone() {
        let router = SplitRouter<TestRoute>()
        router.presentSheet(route: .settings)

        #expect(router.presentingSheet?.route == .settings)
        #expect(router.sidebar.presentingSheet == nil)
    }

    /// A screen modal and a detail-local one are the same slot now, so the
    /// second replaces the first. That matches what the screen does anyway:
    /// UIKit shows one modal per view-controller chain (verified on iPad).
    /// Use `target: .deepest` to stack.
    @MainActor
    @Test func screenAndDetailModalsShareOneSlot() {
        let router = SplitRouter<TestRoute>()
        router.presentSheet(route: .profile)
        router.presentSheet(route: .settings)

        #expect(router.presentingSheet?.route == .settings)
    }

    #if os(iOS)
    @MainActor
    @Test func screenCoverUsesTheCoverSlot() {
        let router = SplitRouter<TestRoute>()
        router.present(route: .settings)

        #expect(router.presentingFullScreenCover?.route == .settings)
        #expect(router.presentingSheet == nil)
    }
    #endif

    @MainActor
    @Test func sidebarDismissalDoesNotTouchTheScreenModal() {
        let router = SplitRouter<TestRoute>()
        router.sidebar.presentSheet(route: .profile)
        router.presentSheet(route: .settings)

        router.sidebar.dismissChild()

        #expect(router.sidebar.presentingSheet == nil)
        #expect(router.presentingSheet?.route == .settings)
    }

    @MainActor
    @Test func popAllToRootClearsEverySurface() {
        let router = SplitRouter<TestRoute>()
        router.sidebarPath = [.home, .settings]
        router.path = [.profile]
        router.sidebar.presentSheet(route: .profile)
        router.presentSheet(route: .settings)

        router.popAllToRoot()

        #expect(router.isFullyAtRoot)
        #expect(router.sidebar.isFullyAtRoot)
    }

    /// A split router is a `Router`, so it can be handed to anything taking one.
    @MainActor
    @Test func isUsableAsARouter() {
        let router = SplitRouter<TestRoute>()
        let asRouter: Router<TestRoute> = router
        asRouter.presentSheet(route: .settings)
        #expect(router.presentingSheet?.route == .settings)
    }
}

// MARK: - SplitRouter observation

@Suite("SplitRouter observation")
struct SplitRouterObservationTests {
    private final class Box: @unchecked Sendable { var fired = false }

    /// The split router inherits observation from `Router`, so its own
    /// screen-level state is tracked without re-annotating the subclass.
    @MainActor
    @Test func screenLevelStateIsObserved() {
        let router = SplitRouter<TestRoute>()
        let box = Box()
        withObservationTracking {
            _ = router.presentingSheet
        } onChange: {
            box.fired = true
        }
        router.presentSheet(route: .settings)
        #expect(box.fired)
    }

    /// Column state is observed through each column's own router.
    @MainActor
    @Test func columnStateIsObserved() {
        let router = SplitRouter<TestRoute>()
        let box = Box()
        withObservationTracking {
            _ = router.sidebarPath
        } onChange: {
            box.fired = true
        }
        router.sidebarPath.append(.home)
        #expect(box.fired)
    }

    /// `SplitRouter` re-declares `@Observable` over an already-observable
    /// superclass. That is load-bearing: without it the layout properties it
    /// adds would mutate silently and no view would redraw.
    @MainActor
    @Test func layoutStateIsObserved() {
        let router = SplitRouter<TestRoute>()
        let box = Box()
        withObservationTracking {
            _ = router.isCollapsed
        } onChange: {
            box.fired = true
        }
        router.isCollapsed = true
        #expect(box.fired)
    }
}

// MARK: - Replace In Place

@Suite("Replace In Place")
struct ReplaceInPlaceTests {
    /// Presenting stores the route as its own presentation identity.
    @MainActor
    @Test func presentingUsesTheRouteAsIdentity() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .home)
        #expect(router.presentingSheet?.id == .home)

        router.presentSheet(route: .settings)
        #expect(router.presentingSheet?.id == .settings)
    }

    /// Direct assignment behaves like a fresh present — new identity.
    @MainActor
    @Test func directAssignmentIsAFreshPresentation() {
        let router = Router<TestRoute>()
        router.presentingSheet = .init(.home)
        #expect(router.presentingSheet?.id == .home)

        router.presentingSheet = .init(.settings)
        #expect(router.presentingSheet?.id == .settings)
    }

    /// `replace` swaps the route while keeping the presentation's id, so
    /// `sheet(item:)` replaces the view in place.
    @MainActor
    @Test func replaceKeepsThePresentationIdentity() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .home, options: .init(detents: [.medium]))
        let child = router.routerFor(routeType: .sheet, toShow: .home)

        child.replace(with: .settings)

        #expect(router.presentingSheet?.route == .settings)
        #expect(router.presentingSheet?.id == .home)
        #expect(router.presentingSheet?.sheetOptions.detents == [.medium])
    }

    #if os(iOS)
    @MainActor
    @Test func replaceKeepsTheCoverIdentity() {
        let router = Router<TestRoute>()
        router.present(route: .home)
        let child = router.routerFor(routeType: .fullScreenCover, toShow: .home)

        child.replace(with: .settings)

        #expect(router.presentingFullScreenCover?.route == .settings)
        #expect(router.presentingFullScreenCover?.id == .home)
        #expect(router.presentingFullScreenCover?.navigation.dismissOptions == .visible)
    }
    #endif

    /// The presenting side can swap its own modal's content — the case
    /// `replace` cannot serve, since that reaches for a *parent*.
    @MainActor
    @Test func replacePresentedSwapsFromThePresentingSide() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .home, options: .init(detents: [.medium]))

        router.replacePresented(with: .settings)

        #expect(router.presentingSheet?.route == .settings)
        #expect(router.presentingSheet?.id == .home)
        #expect(router.presentingSheet?.sheetOptions.detents == [.medium])
    }

    /// Nothing presented, nothing to swap.
    @MainActor
    @Test func replacePresentedIsANoOpWhenNotPresenting() {
        let router = Router<TestRoute>()
        router.replacePresented(with: .settings)
        #expect(router.presentingSheet == nil)
        #expect(!router.isPresenting)
    }

    /// The replacement route gets a fresh child router — the old modal's
    /// stack must not leak into the new content.
    @MainActor
    @Test func replacementGetsAFreshChildRouter() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .home)
        let oldChild = router.routerFor(routeType: .sheet, toShow: .home)
        oldChild.push(route: .profile)

        oldChild.replace(with: .settings)
        let newChild = router.routerFor(routeType: .sheet, toShow: .settings)

        #expect(newChild !== oldChild)
        #expect(newChild.path.isEmpty)
    }

    @MainActor
    @Test func dismissalClearsThePresentation() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .home)
        router.dismissChild()
        #expect(router.presentingSheet == nil)
        #expect(router.presentingSheet == nil)
    }
}

// MARK: - Root Destination

@Suite("Root Destination")
struct RootDestinationTests {
    @MainActor
    @Test func startRecordsTheRoot() {
        let router = Router<TestRoute>()
        #expect(router.rootDestination == nil)
        _ = router.start(.home)
        #expect(router.rootDestination == .home)
    }

    /// A conditional root (`hasFolders ? .folders : .empty`) re-runs `start`
    /// with a new route; the router follows it.
    @MainActor
    @Test func startTracksTheLatestRoot() {
        let router = Router<TestRoute>()
        _ = router.start(.home)
        _ = router.start(.settings)
        #expect(router.rootDestination == .settings)
    }

    @MainActor
    @Test func currentDestinationIsTheRootWhenNothingIsPushed() {
        let router = Router<TestRoute>()
        #expect(router.currentDestination == nil)
        _ = router.start(.home)
        #expect(router.currentDestination == .home)
        #expect(router.currentDestinationIs(.home))
    }

    @MainActor
    @Test func currentDestinationIsTheTopOfThePath() {
        let router = Router<TestRoute>()
        _ = router.start(.home)
        router.push(route: .settings)
        router.push(route: .profile)
        #expect(router.currentDestination == .profile)
        #expect(!router.currentDestinationIs(.home))
    }

    @MainActor
    @Test func previousDestinationIsWhatPopReveals() {
        let router = Router<TestRoute>()
        _ = router.start(.home)
        #expect(router.previousDestination == .home)
        router.push(route: .settings)
        #expect(router.previousDestination == .home)
        router.push(route: .profile)
        #expect(router.previousDestination == .settings)
        router.pop()
        #expect(router.previousDestination == .home)
    }

    @MainActor
    @Test func routingViewRootInitializerConstructs() {
        let router = Router<TestRoute>()
        _ = RoutingView(router, root: .home)
        _ = RoutingView(router, root: .home, dismissOptions: .visible)
        #expect(router.isFullyAtRoot)
    }
}

// MARK: - Route-level navigation default

@Suite("Route-level navigation default")
struct OwnsNavigationTests {
    @MainActor
    @Test func routesDefaultToAStack() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
        #expect(router.presentingSheet?.navigation == .stack(dismiss: nil))
        #expect(!TestRoute.settings.ownsNavigation)
    }

    @MainActor
    @Test func aRouteThatOwnsNavigationPresentsBare() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .share)
        #expect(router.presentingSheet?.navigation == .own)
        #if os(iOS)
        router.present(route: .share)
        #expect(router.presentingFullScreenCover?.navigation == .own)
        #endif
    }

    @MainActor
    @Test func presentedAndDeepestRouter() {
        let root = Router<TestRoute>()
        #expect(root.presented == nil)
        #expect(root.deepestRouter === root)
        root.presentSheet(route: .settings)
        let child = root.routerFor(routeType: .sheet, toShow: .settings)
        #expect(root.presented?.route == .settings)
        #expect(root.deepestRouter === child)
        child.presentSheet(route: .share)
        let grandchild = child.routerFor(routeType: .sheet, toShow: .share)
        #expect(child.presented?.route == .share)
        #expect(root.deepestRouter === grandchild, ".own content gets a child router like any presentation")
    }
}

// MARK: - Transitions

@Suite("Transitions")
struct TransitionTests {
    @MainActor
    @Test func presentationsKeepTheirTransition() {
        let router = Router<TestRoute>()
        let transition = PresentationTransition.zoom(sourceID: "card")
        router.presentSheet(route: .settings, transition: transition)
        #expect(router.presentingSheet?.transition == transition)

        let child = router.routerFor(routeType: .sheet, toShow: .settings)
        child.replace(with: .profile)
        #expect(router.presentingSheet?.transition == transition, "replace keeps the presentation's transition")
    }

    @MainActor
    @Test func pushTransitionsLiveWithThePath() {
        let router = Router<TestRoute>()
        let transition = PresentationTransition.zoom(sourceID: "card")
        router.push(route: .detail("1"), transition: transition)
        router.push(route: .settings)
        #expect(router.pushTransitions[.detail("1")] == transition)
        #expect(router.pushTransitions[.settings] == nil)

        router.popToRoot()
        #expect(router.pushTransitions.isEmpty)
    }
}
