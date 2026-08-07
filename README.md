# Router

<img src="assets/router-hero.svg" alt="Router" width="100%" />

A lightweight SwiftUI navigation library that decouples routing logic from views. Built on `@Observable` for iOS 17+.

<img width="320" height="703" alt="output_1776425725010" src="assets/demo.gif" />

## Why Router?

Most SwiftUI routing libraries scope navigation to a single `NavigationStack`. Router goes further:

- **Any screen, from anywhere** — Define a single route enum wrapping per-feature routes, and any screen can be pushed, presented as a sheet, or shown as a full-screen cover from any tab. No passing routers between views, no manual wiring.
- **Hierarchical navigation** — Routers form a parent-child chain when modals are presented. `NavigationTarget` lets you direct actions to any point in the hierarchy — present on the root, push on the parent, or stack on the deepest child.
- **Modern Swift** — Built on `@Observable` and `@Environment`, not legacy `ObservableObject` and `@EnvironmentObject`.
- **Deep linking with tab support** — Handle deep links that switch tabs and navigate within them, using a single `.onDeepLink` modifier.

## Features

- **Type-safe routing** via `Routable` enums — each case maps to a view
- **Push, sheet, and full-screen cover** navigation with one generic `Router<Destination>`
- **NavigationSplitView support** — `SplitRoutingView` + `SplitRouter` give each column its own router, plus screen-level modals
- **Presentation without a stack** — `.routerPresentations(_:)` hosts router-driven modals on any container (split view, tab view, plain view)
- **NavigationTarget** — route to `.current`, `.parent`, `.root`, or `.deepest` router in a hierarchy
- **Cross-tab routing** — routers injected via `@Environment`, accessible from any child view
- **Sheet presentation options** — detents, drag indicator
- **Configurable dismiss buttons** — show/hide, left/right position, show on pushed views within modals
- **Deep linking** — `.onDeepLink` modifier handles both external URLs and internal `openURL` calls
- **Automatic child router management** — modals get their own router, cleaned up on dismiss

## Requirements

- iOS 17+
- macOS 14+
- Swift 6.0+

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
    dismissOptions: .visible
)
```

### Full-Screen Cover

> `present()` is iOS only. macOS has no full-screen cover equivalent — use `presentSheet(...)` on macOS.

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
router.dismiss()             // ask parent to dismiss this modal
router.dismissOrPopToRoot() // smart dismiss
router.dismissAllFromRoot()  // dismiss entire hierarchy
```

### Stack Manipulation

```swift
router.replaceStack(with: [.home, .detail("1"), .detail("2")])
router.replace(with: .detail("3"))          // swap the top
router.replace(last: 2, with: .detail("3")) // collapse the last two
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

## NavigationSplitView

A split view has multiple independent navigation surfaces — the sidebar stack, the detail stack, and modals that belong to the whole screen. `SplitRouter` owns all three, and `SplitRoutingView` renders them, the same way `RoutingView` pairs with a single `Router`.

The three surfaces can share one route enum — any route can then go anywhere:

```swift
enum AppRoute: Routable { ... }

let appRouter = SplitRouter<AppRoute, AppRoute, AppRoute>()

SplitRoutingView(appRouter) { sidebar in
    sidebar.start(.folders)
} detail: { detail in
    detail.start(.overview)
}
```

Navigate through the facade or the underlying routers directly:

```swift
appRouter.pushSidebar(.folder(id))     // sidebar column stack
appRouter.pushDetail(.article(id))     // detail column stack
appRouter.presentModal(.settings)      // sheet/cover above the whole split view
appRouter.detail.presentSheet(route: .filters)  // column-local modal

appRouter.sidebarPath                  // direct path access
appRouter.detailPath
appRouter.popAllToRoot()
```

The type parameters are independent, so you can also give each surface its own enum when you want the compiler to reject cross-surface navigation (e.g. a detail-only route can never be pushed onto the sidebar):

```swift
let appRouter = SplitRouter<SidebarRoute, DetailRoute, ModalRoute>()
```

Use `Never` for the modals parameter when a screen has no screen-level modals: `SplitRouter<AppRoute, AppRoute, Never>`.

`SplitRoutingView` also passes through `columnVisibility` and `preferredCompactColumn` bindings when you need them.

> **Sidebar rows: prefer `List(selection:)`.** In compact width (iPhone, iPad Split View), `NavigationSplitView` only switches to the detail pane automatically when navigation comes from a `List` selection change. Plain `Button` rows swap state without moving the user, which reads as "nothing happened" on iPhone — if you use them, drive the `preferredCompactColumn` binding yourself. A clean pattern that keeps your coordinator in charge is a custom binding:
>
> ```swift
> List(selection: Binding(
>     get: { coordinator.selection },
>     set: { coordinator.select($0) }   // choreography lives in one place
> )) { ... }
> ```

### Presenting from containers without a stack

`RoutingView` bundles a `NavigationStack` with modal hosting. When the presenting context owns its navigation — a split view, a `TabView`, or a stack driven elsewhere — attach just the modal hosting:

```swift
NavigationSplitView { sidebar } detail: { detail }
    .routerPresentations(modalsRouter)

modalsRouter.presentSheet(route: .settings)
```

### Destinations that own their navigation

Presented routes are normally wrapped in a `RoutingView` so they can push and present further. If a destination *is* a navigation container (a `NavigationSplitView`, or a view that builds its own `NavigationStack`), declare it on the route and it presents bare:

```swift
enum ModalRoute: Routable {
    case fullScreenWorkspace

    var providesOwnNavigation: Bool { true }

    func destination() -> some View { WorkspaceSplitView() }
}
```

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
    @Environment(AppRouter.self) var router

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

The presenter chooses the dismiss button for the modal it shows, so pass the
options when presenting — a router's own `dismissOptions` is read-only.
`.visible` (a leading button) and `.hidden` (none) cover the common cases:

```swift
// Full-screen cover with dismiss button on the left (.visible is the default)
router.present(route: .settings)

// Sheet with a dismiss button (sheets default to .hidden — they swipe away)
router.presentSheet(route: .settings, dismissOptions: .visible)

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
