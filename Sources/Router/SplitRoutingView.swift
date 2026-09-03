import SwiftUI

/// A router-driven `NavigationSplitView`. The detail column is driven by the
/// split router itself, the sidebar by its ``SplitRouter/sidebar``.
///
/// At compact width SwiftUI collapses the columns into a single stack —
/// `sidebar root → detail root → detail path…` — so a cross-column `push`
/// lands two levels deep. Branch on ``SplitRouter/isCollapsed`` when a push
/// should read as one level.
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
        self.sidebarRoute = sidebar
        self.detailRoute = detail
    }

    public var body: some View {
        splitView
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
    /// and the screen's modals.
    private var detailColumn: some View {
        RoutingView(router, root: detailRoute)
    }
}
