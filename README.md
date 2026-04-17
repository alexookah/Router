# Router

A lightweight SwiftUI navigation library that decouples routing logic from views. Built on `@Observable` for iOS 17+.

<img width="320" height="703" alt="output_1776425725010" src="https://github.com/user-attachments/assets/dc7b945f-11d0-4f9d-a4c1-6b3a0ba64a61" />

## Why Router?

Most SwiftUI routing libraries scope navigation to a single `NavigationStack`. Router goes further:

- **Any screen, from anywhere** — Define a single route enum wrapping per-feature routes, and any screen can be pushed, presented as a sheet, or shown as a full-screen cover from any tab. No passing routers between views, no manual wiring.
- **Hierarchical navigation** — Routers form a parent-child chain when modals are presented. `NavigationTarget` lets you direct actions to any point in the hierarchy — present on the root, push on the parent, or stack on the deepest child.
- **Modern Swift** — Built on `@Observable` and `@Environment`, not legacy `ObservableObject` and `@EnvironmentObject`.
- **Deep linking with tab support** — Handle deep links that switch tabs and navigate within them, using a single `.onDeepLink` modifier.

## Features

- **Type-safe routing** via `Routable` enums — each case maps to a view
- **Push, sheet, and full-screen cover** navigation with one generic `Router<Destination>`
- **NavigationTarget** — route to `.current`, `.parent`, `.root`, or `.deepest` router in a hierarchy
- **Cross-tab routing** — routers injected via `@Environment`, accessible from any child view
- **Sheet presentation options** — detents, drag indicator
- **Configurable dismiss buttons** — show/hide, left/right position, show on pushed views within modals
- **Deep linking** — `.onDeepLink` modifier handles both external URLs and internal `openURL` calls
- **Automatic child router management** — modals get their own router, cleaned up on dismiss

## Requirements

- iOS 17+
- Swift 5.9+

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/alexookah/Router.git", from: "1.0.0")
]
```

Or in Xcode: File > Add Package Dependencies and paste the repository URL.

## Quick Start

### 1. Define your routes

```swift
import Router

enum HomeRoute: Routable {
    case home
    case detail(String)
    case settings

    func destination() -> some View {
        switch self {
        case .home: HomeView()
        case let .detail(id): DetailView(id: id)
        case .settings: SettingsView()
        }
    }
}
```

### 2. Wrap your content in RoutingView

```swift
struct ContentView: View {
    @State var router = Router<HomeRoute>()

    var body: some View {
        RoutingView(router) { router in
            router.start(.home)
        }
    }
}
```

### 3. Navigate from any child view

The router is automatically injected into the SwiftUI environment:

```swift
struct HomeView: View {
    @Environment(Router<HomeRoute>.self) var router

    var body: some View {
        Button("Show Detail") {
            router.push(route: .detail("123"))
        }

        Button("Open Settings Sheet") {
            router.presentSheet(
                route: .settings,
                options: .init(detents: [.medium, .large])
            )
        }

        Button("Open Settings Full Screen") {
            router.present(route: .settings)
        }
    }
}
```

## Navigation API

### Push

```swift
router.push(route: .detail("123"))
router.push(route: .detail("123"), target: .root) // push on root router
```

### Sheet

```swift
router.presentSheet(route: .settings)
router.presentSheet(
    route: .settings,
    options: .init(detents: [.medium, .large], dragIndicator: .visible),
    dismissOptions: .init(showDismissButton: true)
)
```

### Full-Screen Cover

```swift
router.present(route: .settings)
router.present(
    route: .settings,
    dismissOptions: .init(
        showDismissButton: true,
        dismissButtonPosition: .left,
        showDismissButtonOnPush: true  // show X on views pushed within the modal
    )
)
```

### Pop & Dismiss

```swift
router.pop()                // go back one
router.pop(last: 3)         // go back three
router.popToRoot()           // clear the stack

router.dismissChild()        // dismiss current sheet/fullScreenCover
router.dismissSelf()         // ask parent to dismiss this modal
router.dismissSelfOrPopToRoot() // smart dismiss
router.dismissAllFromRoot()  // dismiss entire hierarchy
```

### Stack Manipulation

```swift
router.replaceNavigationStack(with: [.home, .detail("1"), .detail("2")])
router.replaceLast(with: .detail("3"))
router.lastPathIs(.detail("3")) // true
```

## Router Hierarchy

When you present a sheet or full-screen cover, Router automatically creates a **child router** for the modal. This forms a parent-child chain:

```
Root Router (tab)
  └── Child Router (sheet)
        └── Child Router (full-screen cover inside the sheet)
```

Each child has a reference to its parent. When a modal is dismissed, its child router is automatically cleaned up.

### NavigationTarget

`NavigationTarget` lets you direct navigation actions to any point in this hierarchy:

| Target | Description |
|--------|-------------|
| `.current` | This router (default) |
| `.parent` | The parent router |
| `.child` | The child router |
| `.root` | The top-most router in the chain |
| `.deepest` | The furthest child (leaf) in the chain |

```swift
// From inside a sheet, push on the parent's navigation stack
router.push(route: .detail("1"), target: .parent)

// From anywhere, present on the root router
router.presentSheet(route: .settings, target: .root)

// Stack a modal on top of an existing modal
router.presentSheet(route: .profile, target: .deepest)
```

This enables cross-tab routing and modal stacking without passing routers around manually.

## Cross-Tab Routing

Use a single route enum wrapping per-feature routes. Each tab gets its own router, and any view can navigate across tabs:

```swift
// Define a top-level route
enum AppRoute: Routable {
    case home(HomeRoute)
    case profile(ProfileRoute)
    case search(SearchRoute)

    func destination() -> some View {
        switch self {
        case let .home(route): route.destination()
        case let .profile(route): route.destination()
        case let .search(route): route.destination()
        }
    }
}

typealias AppRouter = Router<AppRoute>

// One router per tab
struct MainTabView: View {
    @State var homeRouter = AppRouter()
    @State var profileRouter = AppRouter()

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                RoutingView(homeRouter) { $0.start(.home(.home)) }
            }
            Tab("Profile", systemImage: "person") {
                RoutingView(profileRouter) { $0.start(.profile(.profile)) }
            }
        }
    }
}

// From any child view — present a profile screen from the home tab
struct HomeView: View {
    @Environment(Router<AppRoute>.self) var router

    var body: some View {
        Button("View Profile") {
            router.presentSheet(route: .profile(.profile), target: .root)
        }
    }
}
```

## Deep Linking

The `.onDeepLink` modifier handles URLs from both external sources (Safari, push notifications) and internal `openURL` calls. Return `true` if the URL was handled, `false` to pass it to the system.

```swift
TabView(selection: $selectedTab) {
    // tabs...
}
.onDeepLink { url in
    guard url.scheme == "myapp",
          let host = url.host else { return false }

    switch host {
    case "home":
        selectedTab = .home
        if let id = url.pathComponents.dropFirst().first {
            homeRouter.push(route: .home(.detail(id)))
        }
    case "profile":
        selectedTab = .profile
    default:
        return false
    }
    return true
}
```

## Dismiss Button Options

Control the dismiss button on modals:

```swift
// Full-screen cover with dismiss button on the left (default)
router.present(route: .settings)

// Dismiss button on the right
router.present(
    route: .settings,
    dismissOptions: .init(dismissButtonPosition: .right)
)

// Show dismiss button on pushed views within a modal
router.present(
    route: .settings,
    dismissOptions: .init(
        showDismissButton: true,
        showDismissButtonOnPush: true
    )
)

// Sheet with dismiss button (sheets hide it by default since they have swipe-to-dismiss)
router.presentSheet(
    route: .settings,
    dismissOptions: .init(showDismissButton: true)
)
```

## Example App

The `ExampleRouterDemo` Xcode project demonstrates all features with a 4-tab app:

- **Home** — push navigation, full-screen covers, cross-tab routing
- **Stacking** — present sheets on top of sheets using `target: .deepest`, dismiss all with `dismissAllFromRoot()`
- **Profile** — full-screen cover with dismiss button positioning
- **Deep Links** — tappable deep link URLs that trigger tab switching and navigation

To run it, open `ExampleRouterDemo/ExampleRouterDemo.xcodeproj` — the Router package is already included as a local dependency.

## License

MIT

---

If you find Router useful, give it a :star: — it helps others discover the project.
