import SwiftUI

/// Who supplies the navigation container for a presented route.
///
/// The two cases are exclusive by construction: a destination that brings its
/// own container also brings its own chrome, so there are no dismiss options
/// to configure — use `@Environment(\.dismiss)` inside it.
public enum PresentedNavigation: Equatable {
    /// The router wraps the destination in a `RoutingView`, so it can push and
    /// present further, with `dismiss` controlling the dismiss button.
    case stack(dismiss: DismissButtonPresentationOptions)
    /// The destination builds its own `NavigationStack` / `NavigationSplitView`
    /// and is presented as-is.
    case own

    /// The dismiss button configuration, or `nil` when the destination owns
    /// its navigation.
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
    /// Fixed for the presentation, so `replace` keeps it — swap only between
    /// routes that agree on it.
    public var navigation: PresentedNavigation
    public var sheetOptions: SheetPresentationOptions

    public init(
        _ route: Destination,
        navigation: PresentedNavigation = .stack(dismiss: .hidden),
        sheetOptions: SheetPresentationOptions = .init()
    ) {
        self.id = route
        self.route = route
        self.navigation = navigation
        self.sheetOptions = sheetOptions
    }

    /// A copy showing `route` under the same identity.
    func replacing(_ route: Destination) -> Self {
        var copy = self
        copy.route = route
        return copy
    }
}
