import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
///
/// Conforming types are required to be `Hashable` and `Identifiable` because
/// `NavigationStack` uses `Hashable` for its path and `sheet(item:)` uses `Identifiable`
/// for diffing. A default `id` is provided that returns `self`.
///
/// `destination()` is not actor-isolated — building a SwiftUI `View` value is
/// cheap and safe from any context, and SwiftUI evaluates view bodies on the
/// main actor at use time. Leaving the requirement nonisolated lets conformers
/// stay value types that satisfy `Hashable`/`Identifiable` cleanly under Swift 6
/// strict concurrency.
public protocol Routable: Hashable, Identifiable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType
}

extension Routable {
    public nonisolated var id: Self { self }
}
