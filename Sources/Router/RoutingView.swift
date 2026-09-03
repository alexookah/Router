import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View
    where Destination.ViewType == Content
{
    @Bindable var router: Router<Destination>
    private let rootContent: (Router<Destination>) -> Content

    /// The dismiss button for this stack, or `nil` for none. Set by
    /// `RouterPresentationsModifier` for the content it presents; a
    /// `RoutingView` built anywhere else shows no button unless asked.
    private let dismissOptions: DismissButtonPresentationOptions?

    public init(
        _ router: Router<Destination>,
        dismissOptions: DismissButtonPresentationOptions? = nil,
        @ViewBuilder content: @escaping (Router<Destination>) -> Content
    ) {
        self.router = router
        self.dismissOptions = dismissOptions
        self.rootContent = content
    }

    /// A stack rooted at `root` — the common case. The closure form is for
    /// content that needs more than a route.
    public init(
        _ router: Router<Destination>,
        root: Destination,
        dismissOptions: DismissButtonPresentationOptions? = nil
    ) {
        self.init(router, dismissOptions: dismissOptions) { $0.start(root) }
    }

    /// The same button on pushed views, only when the options ask for it.
    private var pushDismissOptions: DismissButtonPresentationOptions? {
        dismissOptions?.showDismissButtonOnPush == true ? dismissOptions : nil
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent(router)
                .ifLet(dismissOptions) { view, options in
                    view.toolbar {
                        DismissToolbar(
                            dismissOptions: options,
                            dismissAction: router.dismissOrPopToRoot
                        )
                    }
                }
                .navigationDestination(for: Destination.self) { route in
                    route.destination()
                        .ifLet(pushDismissOptions) { view, options in
                            view.toolbar {
                                DismissToolbar(
                                    dismissOptions: options,
                                    dismissAction: router.dismissOrPopToRoot
                                )
                            }
                        }
                }
        }
        .modifier(RouterPresentationsModifier(router: router))
        .environment(router)
    }
}
