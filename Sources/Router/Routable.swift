import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination
/// type for `Router`.
///
/// `Hashable` is all navigation needs: `NavigationStack` paths and
/// `PresentedRoute`'s identity both hash the route. No `Identifiable`
/// conformance is claimed, so a route's own `id` stays the app's to define.
///
/// The protocol itself is nonisolated so the inherited `Hashable` witnesses
/// work from any context. `destination()` alone is main-actor isolated: it
/// builds views, and usually their view models, and every caller in the
/// package already runs there. Conformances need no annotation in any
/// language mode or default isolation.
public protocol Routable: Hashable {
    associatedtype ViewType: View
    @MainActor @ViewBuilder func destination() -> ViewType

    /// Whether the destination brings its own navigation container (a stack, a
    /// split view, or a UIKit controller with its own bar); if so it is presented bare.
    var ownsNavigation: Bool { get }
}

public extension Routable {
    var ownsNavigation: Bool { false }
}
