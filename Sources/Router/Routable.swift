import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
///
/// Conforming types are required to be `Hashable` and `Identifiable` because
/// `NavigationStack` uses `Hashable` for its path and `sheet(item:)` uses `Identifiable`
/// for diffing. A default `id` is provided that returns `self`.
///
/// Stays nonisolated so the inherited `Hashable`/`Identifiable` witnesses work
/// from any context. Targets that default to `@MainActor` isolation conform as
/// `enum MyRoute: @MainActor Routable`.
public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType

    /// `true` if the destination brings its own `NavigationStack` or
    /// `NavigationSplitView`. Those are presented bare — nesting navigation
    /// containers doesn't work.
    nonisolated var providesOwnNavigation: Bool { get }
}

extension Routable {
    public nonisolated var id: Self { self }

    public nonisolated var providesOwnNavigation: Bool { false }
}

/// `Never` is the route type for an unused router — e.g. a `SplitRouter`
/// without screen-level modals. Nothing can be pushed or presented on it.
extension Never: Routable {
    public func destination() -> Never {
        fatalError("Never has no routes")
    }
}
