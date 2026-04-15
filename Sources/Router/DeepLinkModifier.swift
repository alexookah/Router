import SwiftUI

struct DeepLinkModifier: ViewModifier {
    let handleDeepLink: (URL) -> Void

    func body(content: Content) -> some View {
        content
            .onOpenURL { url in
                handleDeepLink(url)
            }
    }
}

public extension View {
    func onDeepLink(
        _ handleDeepLink: @escaping (URL) -> Void
    ) -> some View {
        self.modifier(DeepLinkModifier(handleDeepLink: handleDeepLink))
    }
}
