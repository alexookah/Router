import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
///
/// Conforming types are required to be `Hashable` and `Identifiable` because
/// `NavigationStack` uses `Hashable` for its path and `sheet(item:)` uses `Identifiable`
/// for diffing. A default `id` is provided that returns `self`.
///
/// Only `destination()` is `@MainActor`-isolated — the conforming type itself is
/// not, so it can satisfy `Hashable` and `Identifiable` without crossing actor boundaries.
public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @MainActor @ViewBuilder func destination() -> ViewType
}

extension Routable {
    public nonisolated var id: Self { self }
}
