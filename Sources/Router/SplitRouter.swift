import SwiftUI

/// The routing counterpart of a `NavigationSplitView`, used with ``SplitRoutingView``.
///
/// A `SplitRouter` *is* a ``Router`` — the one driving the detail column — so
/// `push`, `presentSheet` and `present` are `Router`'s own API, and modals
/// presented on it show over the whole screen in both layouts. ``sidebar`` is
/// a full `Router` too, so both columns take the same verbs.
///
/// One modal shows at a time; stack modals with `target: .deepest`.
///
/// `@Observable` is re-declared over the already-observable superclass —
/// without it the stored properties below mutate silently.
@MainActor
@Observable
public final class SplitRouter<Destination: Routable>: Router<Destination> {

    public init(
        columnVisibility: NavigationSplitViewVisibility = .automatic,
        preferredCompactColumn: NavigationSplitViewColumn = .sidebar
    ) {
        super.init()
        self.columnVisibility = columnVisibility
        self.preferredCompactColumn = preferredCompactColumn
    }

    // MARK: - Columns

    /// Views inside the sidebar column also reach this as their column-local
    /// router via `@Environment(Router<Destination>.self)`.
    public let sidebar = Router<Destination>()

    public var detail: Router<Destination> { self }

    public var sidebarPath: [Destination] {
        get { sidebar.path }
        set { sidebar.path = newValue }
    }

    // MARK: - Layout

    /// Whether the split view is collapsed to a single pane (compact width).
    ///
    /// Maintained by ``SplitRoutingView``, which sits outside the split view
    /// and so sees the window's size class. Views inside a column must not
    /// derive this from `horizontalSizeClass`: a column reports its own width,
    /// so a narrow sidebar on a full-size iPad reads as `.compact` while both
    /// panes are visible.
    public internal(set) var isCollapsed: Bool = false

    /// Which column a collapsed split view shows. SwiftUI writes back as the
    /// user navigates, but does not reliably follow a column's own selection
    /// when that column has its own `NavigationStack` — set it explicitly
    /// alongside the navigation that should be visible.
    public var preferredCompactColumn: NavigationSplitViewColumn = .sidebar

    /// Sidebar visibility in the expanded layout, defaulting to SwiftUI's own
    /// `.automatic`.
    ///
    /// Bound explicitly, `.automatic` is *not* the same as an unbound
    /// `NavigationSplitView`: measured on iPad, it starts the sidebar hidden.
    /// Set `.all` to show both columns from launch.
    public var columnVisibility: NavigationSplitViewVisibility = .automatic

    // MARK: - Navigation

    public func popAllToRoot() {
        sidebar.popToRoot()
        sidebar.dismissChild()
        popToRoot()
        dismissChild()
    }
}
