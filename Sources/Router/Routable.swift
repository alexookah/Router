import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination
/// type for `Router`.
///
/// `Hashable` is all navigation needs: `NavigationStack` paths and
/// `PresentedRoute`'s identity both hash the route. No `Identifiable`
/// conformance is claimed, so a route's own `id` stays the app's to define.
///
/// Stays nonisolated so the inherited `Hashable` witnesses work from any
/// context. Targets that default to `@MainActor` isolation conform as
/// `enum MyRoute: @MainActor Routable`.
public protocol Routable: Hashable {
    associatedtype ViewType: View
    @ViewBuilder func destination() -> ViewType
}
