import SwiftUI

/// A type that maps an enum case to a SwiftUI view, used as the destination type for `Router`.
///
/// `Hashable` and `Identifiable` are required by `Router`/`RoutingView` (NavigationStack
/// path + sheet item bindings), but are intentionally not inherited here — inheriting
/// nonisolated stdlib protocols would force every conformance to use isolated-conformance
/// syntax. Requiring them at the use site (via the `Route` typealias) keeps route
/// conformances clean.
///
/// Only `destination()` is `@MainActor`-isolated — the conforming type itself stays
/// nonisolated so it can satisfy `Identifiable`/`Hashable` without crossing actor boundaries.
public protocol Routable {
    associatedtype ViewType: View
    @MainActor @ViewBuilder func destination() -> ViewType
}

/// Convenience composition for a fully usable route type — the conformance bundle
/// `Router`/`RoutingView` requires.
///
/// Use on route enums:
/// ```swift
/// enum MyRoute: Route {
///     case home, detail(Item)
/// }
///
/// extension MyRoute {
///     @ViewBuilder func destination() -> some View {
///         switch self {
///         case .home: HomeView()
///         case let .detail(item): DetailView(item: item)
///         }
///     }
/// }
/// ```
///
/// Note: this is a protocol *composition*, not a new protocol inheriting all three.
/// A new protocol with `protocol Route: Routable, Hashable, Identifiable` would
/// re-introduce the `@MainActor` / nonisolated conformance crossing this design avoids.
public typealias Route = Routable & Hashable & Identifiable

/// Default `Identifiable.id` for `Route` conformers — uses `self` since route enums
/// are already `Hashable`. Lives on `Identifiable` (not `Routable`) so Swift's witness
/// inference can find it when satisfying the `Identifiable` conformance.
extension Identifiable where Self: Routable & Hashable {
    public var id: Self { self }
}
