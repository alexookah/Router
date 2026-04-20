import SwiftUI
import Testing
@testable import Router

// MARK: - Test Route

enum TestRoute: Routable {
    case home
    case detail(String)
    case settings
    case profile

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
        }
    }
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
    @Test func replaceNavigationStack() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.replaceNavigationStack(with: [.settings, .profile])
        #expect(router.path == [.settings, .profile])
    }

    @MainActor
    @Test func replaceLastOnNonEmpty() {
        let router = Router<TestRoute>()
        router.push(route: .home)
        router.push(route: .settings)
        router.replaceLast(with: .profile)
        #expect(router.path == [.home, .profile])
    }

    @MainActor
    @Test func replaceLastOnEmpty() {
        let router = Router<TestRoute>()
        router.replaceLast(with: .profile)
        #expect(router.path == [.profile])
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
        #expect(router.presentingSheet == .settings)
        #expect(router.isPresenting)
    }

    @MainActor
    @Test func presentSheetWithOptions() {
        let router = Router<TestRoute>()
        let options = SheetPresentationOptions(detents: [.medium], dragIndicator: .hidden)
        router.presentSheet(route: .settings, options: options)
        #expect(router.sheetPresentationOptions == options)
    }
}

// MARK: - Full Screen Cover

@Suite("Full Screen Cover")
struct FullScreenCoverTests {
    @MainActor
    @Test func presentFullScreenCover() {
        let router = Router<TestRoute>()
        router.present(route: .profile)
        #expect(router.presentingFullScreenCover == .profile)
        #expect(router.isPresenting)
    }
}

// MARK: - Dismissal

@Suite("Dismissal")
struct DismissalTests {
    @MainActor
    @Test func dismissChild() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
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
        let child = parent.routerFor(routeType: .sheet)
        child.dismiss()
        #expect(parent.presentingSheet == nil)
        #expect(!parent.hasChild)
    }

    @MainActor
    @Test func dismissOrPopToRootDismissesPresentedChild() {
        let parent = Router<TestRoute>()
        parent.presentSheet(route: .settings)
        let child = parent.routerFor(routeType: .sheet)
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
        let child = root.routerFor(routeType: .sheet)
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
        let result = router.routerFor(routeType: .push)
        #expect(result === router)
    }

    @MainActor
    @Test func routerForSheetCreatesChild() {
        let router = Router<TestRoute>()
        let child = router.routerFor(routeType: .sheet)
        #expect(child !== router)
        #expect(router.hasChild)
        #expect(!child.isRootRouter)
    }

    @MainActor
    @Test func routerForSheetReusesChild() {
        let router = Router<TestRoute>()
        let child1 = router.routerFor(routeType: .sheet)
        let child2 = router.routerFor(routeType: .sheet)
        #expect(child1 === child2)
    }

    @MainActor
    @Test func routerForFullScreenCoverCreatesChild() {
        let router = Router<TestRoute>()
        let child = router.routerFor(routeType: .fullScreenCover)
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
        _ = router.routerFor(routeType: .sheet)
        #expect(router.hasChild)
        // Not presenting anything, so child should be cleared
        router.onPresentationDismissed()
        #expect(!router.hasChild)
    }

    @MainActor
    @Test func keepsChildWhenStillPresenting() {
        let router = Router<TestRoute>()
        router.presentSheet(route: .settings)
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
        let child = root.routerFor(routeType: .sheet)
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
        let child = root.routerFor(routeType: .sheet)
        root.push(route: .home, target: .deepest)
        #expect(child.path == [.home])
        #expect(root.path.isEmpty)
    }

    @MainActor
    @Test func pushWithDeepestTargetNoChild() {
        let router = Router<TestRoute>()
        router.push(route: .home, target: .deepest)
        #expect(router.path == [.home])
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

@Suite("showDismissButtonOnPush")
struct ShowDismissButtonOnPushTests {
    @MainActor
    @Test func falseForRootRouter() {
        let router = Router<TestRoute>()
        router.dismissOptions = DismissButtonPresentationOptions(
            showDismissButton: true,
            showDismissButtonOnPush: true
        )
        #expect(!router.showDismissButtonOnPush)
    }

    @MainActor
    @Test func trueWhenAllConditionsMet() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        child.dismissOptions = DismissButtonPresentationOptions(
            showDismissButton: true,
            showDismissButtonOnPush: true
        )
        #expect(child.showDismissButtonOnPush)
    }

    @MainActor
    @Test func falseWhenShowDismissButtonIsFalse() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        child.dismissOptions = DismissButtonPresentationOptions(
            showDismissButton: false,
            showDismissButtonOnPush: true
        )
        #expect(!child.showDismissButtonOnPush)
    }

    @MainActor
    @Test func falseWhenShowDismissButtonOnPushIsFalse() {
        let parent = Router<TestRoute>()
        let child = Router<TestRoute>(parentRouter: parent)
        child.dismissOptions = DismissButtonPresentationOptions(
            showDismissButton: true,
            showDismissButtonOnPush: false
        )
        #expect(!child.showDismissButtonOnPush)
    }
}
