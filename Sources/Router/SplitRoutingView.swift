import SwiftUI

/// A router-driven `NavigationSplitView`. The detail column is driven by the
/// split router itself, the sidebar by its ``SplitRouter/sidebar``.
///
/// At compact width SwiftUI collapses the columns into a single stack —
/// `sidebar root → detail root → detail path…` — so a cross-column `push`
/// lands two levels deep. Sidebar rows use ``SplitRouter/show(_:)`` instead:
/// the pick becomes the detail root, one level deep in either layout.
public struct SplitRoutingView<Destination: Routable>: View {
    @Bindable private var router: SplitRouter<Destination>

    private let sidebarRoute: Destination
    private let detailRoute: Destination

    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    public init(
        _ router: SplitRouter<Destination>,
        sidebar: Destination,
        detail: Destination
    ) {
        self.router = router
        sidebarRoute = sidebar
        detailRoute = detail
    }

    public var body: some View {
        splitView
            #if os(iOS)
            // iPadOS lays a split view out below a top tab bar, leaving a blank
            // strip; the columns' bars still respect the safe area.
            // https://developer.apple.com/forums/thread/825667 (FB22645938)
            .ignoresSafeArea(.container, edges: .top)
            #endif
            .environment(router)
            .onChange(of: isCompactWidth, initial: true) { _, compact in
                router.isCollapsed = compact
            }
    }

    /// Unavailable on macOS, where a `NavigationSplitView` never collapses.
    private var isCompactWidth: Bool {
        #if os(iOS)
            horizontalSizeClass == .compact
        #else
            false
        #endif
    }

    private var splitView: some View {
        NavigationSplitView(
            columnVisibility: $router.columnVisibility,
            preferredCompactColumn: $router.preferredCompactColumn
        ) {
            sidebarColumn
        } detail: {
            detailColumn
        }
    }

    private var sidebarColumn: some View {
        RoutingView(router.sidebar, root: sidebarRoute)
    }

    /// The split router *is* this column's router, so it hosts both this stack
    /// and the screen's modals. Its root is the sidebar's pick, if any.
    private var detailColumn: some View {
        RoutingView(router, root: router.selection ?? detailRoute)
    }
}
