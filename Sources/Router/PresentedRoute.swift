import SwiftUI

/// Who supplies the navigation container for a presented route.
///
/// Only ``stack(dismiss:)`` carries dismiss options: ``own`` content owns its
/// chrome and closes itself with `@Environment(\.dismiss)`.
public enum PresentedNavigation<Destination: Routable>: Equatable {
    /// The router wraps the destination in a `RoutingView`, so it can push and
    /// present further, with `dismiss` controlling the dismiss button.
    case stack(dismiss: DismissButtonPresentationOptions)
    /// The destination builds its own navigation container and is presented
    /// as-is, with no child router. Also the shape for presented split
    /// screens: the destination owns a ``SplitRouter`` and composes a
    /// ``SplitRoutingView``, which is where any state shared by the columns
    /// lives.
    case own

    /// The dismiss button configuration, or `nil` when the presented content
    /// owns its navigation.
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
    public var navigation: PresentedNavigation<Destination>
    public var sheetOptions: SheetPresentationOptions

    public init(
        _ route: Destination,
        navigation: PresentedNavigation<Destination> = .stack(dismiss: .hidden),
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
