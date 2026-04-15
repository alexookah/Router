import SwiftUI

public struct SheetPresentationOptions: Equatable {
    public var detents: Set<PresentationDetent>?
    public var dragIndicator: Visibility

    public init(
        detents: Set<PresentationDetent>? = nil,
        dragIndicator: Visibility = .visible
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

    public static var sheetDismissOptions: DismissButtonPresentationOptions {
        .init(showDismissButton: false)
    }

    public static var fullScreenDismissOptions: DismissButtonPresentationOptions {
        .init()
    }
}
