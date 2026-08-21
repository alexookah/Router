import SwiftUI

public struct SheetPresentationOptions: Equatable {
    public var detents: Set<PresentationDetent>?
    public var dragIndicator: Visibility

    public init(
        detents: Set<PresentationDetent>? = nil,
        dragIndicator: Visibility = .automatic
    ) {
        self.detents = detents
        self.dragIndicator = dragIndicator
    }
}

public struct DismissButtonPresentationOptions: Equatable {
    public enum ButtonPosition: Equatable {
        case left, right
    }

    public var showDismissButton: Bool
    public var dismissButtonPosition: ButtonPosition
    public var showDismissButtonOnPush: Bool

    public init(
        showDismissButton: Bool = true,
        dismissButtonPosition: ButtonPosition = .left,
        showDismissButtonOnPush: Bool = false
    ) {
        self.showDismissButton = showDismissButton
        self.dismissButtonPosition = dismissButtonPosition
        self.showDismissButtonOnPush = showDismissButtonOnPush
    }

    /// No dismiss button — the default for sheets, which swipe away.
    public static var hidden: DismissButtonPresentationOptions {
        .init(showDismissButton: false)
    }

    /// A dismiss button on the leading edge — the default for full-screen covers.
    public static var visible: DismissButtonPresentationOptions {
        .init(showDismissButton: true)
    }
}
