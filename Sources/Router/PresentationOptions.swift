import SwiftUI

public struct SheetPresentationOptions: Equatable {
    public var detents: Set<PresentationDetent>?
    public var dragIndicator: Visibility
    public var isInteractiveDismissDisabled: Bool

    public init(
        detents: Set<PresentationDetent>? = nil,
        dragIndicator: Visibility = .automatic,
        isInteractiveDismissDisabled: Bool = false
    ) {
        self.detents = detents
        self.dragIndicator = dragIndicator
        self.isInteractiveDismissDisabled = isInteractiveDismissDisabled
    }
}

/// How a dismiss button looks, for a presentation that shows one. Whether
/// there is a button is the optional at the use site — `.stack(dismiss: nil)`,
/// `RoutingView(router, dismissOptions: nil)` — so nothing here can disagree
/// with it.
public struct DismissButtonPresentationOptions: Equatable {
    public enum ButtonPosition: Equatable {
        case left, right
    }

    public var dismissButtonPosition: ButtonPosition

    /// Also show the button on views pushed inside the modal, where the back
    /// button would otherwise be the only way out.
    public var showDismissButtonOnPush: Bool

    public init(
        dismissButtonPosition: ButtonPosition = .left,
        showDismissButtonOnPush: Bool = false
    ) {
        self.dismissButtonPosition = dismissButtonPosition
        self.showDismissButtonOnPush = showDismissButtonOnPush
    }

    /// A dismiss button on the leading edge — the default for full-screen covers.
    public static var visible: DismissButtonPresentationOptions {
        .init()
    }
}
