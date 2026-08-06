import SwiftUI

public struct RoutingView<Content: View, Destination: Routable>: View
    where Destination.ViewType == Content
{
    @Bindable var router: Router<Destination>
    private let rootContent: (Router<Destination>) -> Content

    public init(
        _ router: Router<Destination>,
        @ViewBuilder content: @escaping (Router<Destination>) -> Content
    ) {
        self.router = router
        self.rootContent = content
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            rootContent(router)
                .if(!router.isRootRouter && router.dismissOptions.showDismissButton) {
                    $0.toolbar {
                        DismissToolbar(
                            dismissOptions: router.dismissOptions,
                            dismissAction: router.dismissOrPopToRoot
                        )
                    }
                }
                .navigationDestination(for: Destination.self) { route in
                    route.destination()
                        .if(router.showDismissButtonOnPush) {
                            $0.toolbar {
                                DismissToolbar(
                                    dismissOptions: router.dismissOptions,
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
