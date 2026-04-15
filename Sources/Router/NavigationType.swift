import SwiftUI

/// Determines how a destination is presented.
///
/// For `.sheet` and `.fullScreenCover`, associated values carry presentation options.
/// Default values are provided so `.sheet()` and `.fullScreenCover()` work without arguments.
public enum NavigationType {
    /// A push transition onto the navigation stack.
    case push
    /// A sheet presentation with optional detents and drag indicator.
    case sheet(
        options: SheetPresentationOptions = .init(),
        dismissOptions: DismissButtonPresentationOptions = .sheetDismissOptions
    )
    /// A full-screen cover presentation.
    case fullScreenCover(
        dismissOptions: DismissButtonPresentationOptions = .fullScreenDismissOptions
    )
}

/// Controls which router in the hierarchy receives a navigation action.
public enum NavigationTarget {
    /// Use this router instance.
    case current
    /// Use the parent router.
    case parent
    /// Use the child router.
    case child
    /// Use the top-most parent (root) router.
    case root
    /// Use the furthest child in the hierarchy (deepest).
    case deepest
}
