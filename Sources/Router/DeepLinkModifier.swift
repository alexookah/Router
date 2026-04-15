import SwiftUI

struct DeepLinkModifier: ViewModifier {
    let handleDeepLink: (URL) -> Bool

    func body(content: Content) -> some View {
        content
            // Handles deep links from outside the app (Safari, other apps, push notifications)
            .onOpenURL { url in
                _ = handleDeepLink(url)
            }
            // Intercepts openURL() calls from child views within the app
            .environment(\.openURL, OpenURLAction { url in
                handleDeepLink(url) ? .handled : .systemAction
            })
    }
}

public extension View {
    /// Handles deep links from both external sources and internal `openURL` calls.
    ///
    /// This modifier:
    /// 1. Listens for URLs delivered by the system (`.onOpenURL`)
    /// 2. Overrides the `openURL` environment so child views can trigger
    ///    deep links by calling `openURL(url)`
    ///
    /// Return `true` if the URL was handled, `false` to pass it to the system (e.g. open in Safari).
    ///
    /// ```swift
    /// TabView(selection: $selectedTab) { ... }
    /// .onDeepLink { url in
    ///     guard url.scheme == "myapp" else { return false }
    ///     selectedTab = .profile
    ///     profileRouter.push(route: .profile(.editProfile))
    ///     return true
    /// }
    /// ```
    func onDeepLink(
        _ handleDeepLink: @escaping (URL) -> Bool
    ) -> some View {
        self.modifier(DeepLinkModifier(handleDeepLink: handleDeepLink))
    }
}
