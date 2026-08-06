import SwiftUI

/// A router-driven `NavigationSplitView`, paired with a ``SplitRouter`` the
/// same way `RoutingView` pairs with a single `Router`.
///
/// Each column is wrapped in its own `RoutingView`, giving it an independent
/// router-driven `NavigationStack` and the ability to present its own
/// modals. The split router's `modals` router is hosted above the whole
/// split view for screen-level presentations.
///
/// ```swift
/// let appRouter = SplitRouter<SidebarRoute, DetailRoute, ModalRoute>()
///
/// SplitRoutingView(appRouter, preferredCompactColumn: $preferredColumn) { sidebar in
///     sidebar.start(.root)
/// } detail: { detail in
///     detail.start(.overview)
/// }
/// ```
public struct SplitRoutingView<
    SidebarDestination: Routable,
    Sidebar: View,
    DetailDestination: Routable,
    Detail: View,
    ModalDestination: Routable
>: View where SidebarDestination.ViewType == Sidebar, DetailDestination.ViewType == Detail {

    private let router: SplitRouter<SidebarDestination, DetailDestination, ModalDestination>

    private let sidebarContent: (Router<SidebarDestination>) -> Sidebar
    private let detailContent: (Router<DetailDestination>) -> Detail

    /// Optional caller-supplied bindings. When absent, the corresponding
    /// `NavigationSplitView` initializer parameter is omitted entirely — see
    /// the note on `splitView`.
    private let columnVisibility: Binding<NavigationSplitViewVisibility>?
    private let preferredCompactColumn: Binding<NavigationSplitViewColumn>?

    public init(
        _ router: SplitRouter<SidebarDestination, DetailDestination, ModalDestination>,
        columnVisibility: Binding<NavigationSplitViewVisibility>? = nil,
        preferredCompactColumn: Binding<NavigationSplitViewColumn>? = nil,
        @ViewBuilder sidebar: @escaping (Router<SidebarDestination>) -> Sidebar,
        @ViewBuilder detail: @escaping (Router<DetailDestination>) -> Detail
    ) {
        self.router = router
        self.columnVisibility = columnVisibility
        self.preferredCompactColumn = preferredCompactColumn
        self.sidebarContent = sidebar
        self.detailContent = detail
    }

    public var body: some View {
        splitView
            .routerPresentations(router.modals)
            .environment(router)
    }

    @ViewBuilder
    private var splitView: some View {
        switch (columnVisibility, preferredCompactColumn) {
        case let (visibility?, compactColumn?):
            NavigationSplitView(
                columnVisibility: visibility,
                preferredCompactColumn: compactColumn
            ) {
                sidebarColumn
            } detail: {
                detailColumn
            }
        case let (visibility?, nil):
            NavigationSplitView(columnVisibility: visibility) {
                sidebarColumn
            } detail: {
                detailColumn
            }
        case let (nil, compactColumn?):
            NavigationSplitView(preferredCompactColumn: compactColumn) {
                sidebarColumn
            } detail: {
                detailColumn
            }
        case (nil, nil):
            NavigationSplitView {
                sidebarColumn
            } detail: {
                detailColumn
            }
        }
    }

    private var sidebarColumn: some View {
        RoutingView(router.sidebar, content: sidebarContent)
    }

    private var detailColumn: some View {
        RoutingView(router.detail, content: detailContent)
    }
}
