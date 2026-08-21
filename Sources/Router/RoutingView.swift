import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View
    where Destination.ViewType == Content
{
    @Bindable var router: Router<Destination>
    private let rootContent: (Router<Destination>) -> Content

    /// Set by `RouterPresentationsModifier` for the view it presents. Defaults
    /// to `.hidden`, so a `RoutingView` built anywhere else shows no button.
    private let dismissOptions: DismissButtonPresentationOptions

    public init(
        _ router: Router<Destination>,
        dismissOptions: DismissButtonPresentationOptions = .hidden,
        @ViewBuilder content: @escaping (Router<Destination>) -> Content
    ) {
        self.router = router
        self.dismissOptions = dismissOptions
        self.rootContent = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent(router)
                .if(dismissOptions.showDismissButton) {
                    $0.toolbar {
                        DismissToolbar(
                            dismissOptions: dismissOptions,
                            dismissAction: router.dismissOrPopToRoot
                        )
                    }
                }
                .navigationDestination(for: Destination.self) { route in
                    route.destination()
                        .if(dismissOptions.showDismissButton && dismissOptions.showDismissButtonOnPush) {
                            $0.toolbar {
                                DismissToolbar(
                                    dismissOptions: dismissOptions,
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
