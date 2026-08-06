import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
///
/// Conforming types are required to be `Hashable` and `Identifiable` because
/// `NavigationStack` uses `Hashable` for its path and `sheet(item:)` uses `Identifiable`
/// for diffing. A default `id` is provided that returns `self`.
///
/// The protocol is deliberately nonisolated: it refines `Hashable` and
/// `Identifiable`, whose witnesses must stay usable from any context.
/// Targets built with default `@MainActor` isolation declare an isolated
/// conformance instead — `enum MyRoute: @MainActor Routable` — which
/// documents (and enforces) that the conformance is only used on the main
/// actor, where SwiftUI requests destinations anyway.
public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType

    /// Whether this route's destination provides its own navigation
    /// container (a `NavigationStack` or `NavigationSplitView`).
    ///
    /// When `true`, sheet and full-screen-cover presentations host the
    /// destination bare instead of wrapping it in a `RoutingView`, since
    /// nesting navigation containers is unsupported. Defaults to `false`.
    nonisolated var providesOwnNavigation: Bool { get }
}

extension Routable {
    public nonisolated var id: Self { self }

    public nonisolated var providesOwnNavigation: Bool { false }
}

/// Use `Never` as the route type for a router that is intentionally unused,
/// e.g. a `SplitRouter` without screen-level modals:
/// `SplitRouter<SidebarRoute, DetailRoute, Never>`. Such a router is inert —
/// no `Never` value can exist, so nothing can ever be pushed or presented.
extension Never: Routable {
    public func destination() -> Never {
        fatalError("Never has no routes")
    }
}
