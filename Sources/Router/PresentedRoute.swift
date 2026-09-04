import SwiftUI

/// Who supplies the navigation container for a presented route, decided by
/// the route's `ownsNavigation`.
public enum PresentedNavigation<Destination: Routable>: Equatable {
    /// The router wraps the destination in a `RoutingView`, so it can push and
    /// present further. `dismiss` configures the dismiss button; `nil` shows none.
    case stack(dismiss: DismissButtonPresentationOptions?)
    /// Presented without a `RoutingView`, but with a child router hosting its
    /// sheets and covers. Also the shape for presented split screens.
    case own

    /// The dismiss button for a `.stack` presentation; `nil` for none, and always for `.own`.
    public var dismissOptions: DismissButtonPresentationOptions? {
        if case let .stack(dismiss) = self { dismiss } else { nil }
    }
}

/// A presentation: the route it currently shows, the identity it was opened
/// with, and its options. `replace` changes `route` while keeping `id`, which
/// is why the view swaps without the modal coming down.
///
/// Covers both sheets and covers; `sheetOptions` is unused by the latter.
public struct PresentedRoute<Destination: Routable>: Identifiable, Equatable {
    public let id: Destination
    public var route: Destination
    /// Fixed for the presentation — `replace` keeps it; swap only between
    /// routes that agree on it.
    public private(set) var navigation: PresentedNavigation<Destination>
    public let sheetOptions: SheetPresentationOptions
    public let transition: PresentationTransition?

    /// `dismiss` is ignored for a route that owns its navigation.
    public init(
        _ route: Destination,
        dismiss: DismissButtonPresentationOptions? = nil,
        sheetOptions: SheetPresentationOptions = .init(),
        transition: PresentationTransition? = nil
    ) {
        self.id = route
        self.route = route
        self.navigation = route.ownsNavigation ? .own : .stack(dismiss: dismiss)
        self.sheetOptions = sheetOptions
        self.transition = transition
    }

    /// A copy showing `route` under the same identity. The container follows
    /// the new route's `ownsNavigation`; the dismiss button carries over.
    func replacing(_ route: Destination) -> Self {
        var copy = self
        copy.route = route
        copy.navigation = route.ownsNavigation ? .own : .stack(dismiss: navigation.dismissOptions)
        return copy
    }
}
