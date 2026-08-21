//
//  SplitDemoView.swift
//  ExampleRouterDemo
//
//  SplitRoutingView demo. The router lives in MainTabView so deep links can
//  drive it — see the Deep Links tab.
//

import Router
import SwiftUI

struct SplitDemoView: View {
    let router: SplitAppRouter

    var body: some View {
        SplitRoutingView(router, sidebar: .split(.folders), detail: .split(.overview))
    }
}

// MARK: - Sidebar column

struct SplitFoldersView: View {
    @Environment(SplitAppRouter.self) private var router
    /// This column's own router — for column-local presentation.
    @Environment(Router<AppRoute>.self) private var columnRouter

    var body: some View {
        List {
            Section("sidebarPath — drill the sidebar") {
                ForEach(1..<4) { index in
                    Button("Folder \(index)") {
                        router.sidebar.push(route: .split(.folder(index)))
                    }
                }
            }

            Section("Cross-column") {
                Button("push — open an article in detail") {
                    router.push(route: .split(.article(1)))
                }
                Button("push — one level, either layout") {
                    // Collapsed, the columns are one stack (sidebar root →
                    // detail root → detail path), so a detail push lands two
                    // levels deep. Pushing the sidebar instead keeps "back"
                    // meaning "back to Folders".
                    if router.isCollapsed {
                        router.sidebar.push(route: .split(.article(1)))
                    } else {
                        router.push(route: .split(.article(1)))
                    }
                }
            }

            Section("Column-local") {
                Button("presentSheet on this column's router") {
                    columnRouter.presentSheet(route: .split(.filters))
                }
            }
        }
        .navigationTitle("Folders")
    }
}

struct SplitFolderView: View {
    let index: Int
    @Environment(SplitAppRouter.self) private var router

    var body: some View {
        List {
            Button("Drill deeper") {
                router.sidebar.push(route: .split(.folder(index + 1)))
            }
            Button("Open article \(index) in detail") {
                router.push(route: .split(.article(index)))
            }
        }
        .navigationTitle("Folder \(index)")
    }
}

// MARK: - Detail column

struct SplitOverviewView: View {
    @Environment(SplitAppRouter.self) private var router

    var body: some View {
        List {
            Section("Stacks") {
                LabeledContent("sidebarPath", value: "\(router.sidebarPath.count)")
                LabeledContent("path (detail)", value: "\(router.path.count)")
                Button("push") { router.push(route: .split(.article(1))) }
                Button("popAllToRoot") { router.popAllToRoot() }
            }

            Section("Modals — Router's own API") {
                Button("presentSheet") {
                    router.presentSheet(route: .split(.settings))
                }
                Button("presentSheet, medium detent") {
                    router.presentSheet(
                        route: .split(.settings),
                        options: .init(detents: [.medium])
                    )
                }
                #if os(iOS)
                Button("present — full-screen cover") {
                    router.present(route: .split(.editor))
                }
                #endif
                Button("Stack two with target: .deepest") {
                    router.presentSheet(route: .split(.share))
                    router.presentSheet(route: .split(.settings), target: .deepest)
                }
            }

            Section {
                Text("""
                Only one modal shows per view-controller chain — stack with \
                target: .deepest rather than presenting from two surfaces. \
                For deep links into this tab, try the Deep Links tab: \
                routerdemo://split/article/7 pushes Article 7 here, \
                routerdemo://split/folder/2 drills the sidebar.
                """)
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Overview")
    }
}

struct SplitArticleView: View {
    let index: Int
    @Environment(SplitAppRouter.self) private var router

    var body: some View {
        List {
            Button("Push another article") {
                router.push(route: .split(.article(index + 1)))
            }
            Button("replace — swap this screen in place") {
                router.replace(with: .split(.article(index + 100)))
            }
        }
        .navigationTitle("Article \(index)")
    }
}

// MARK: - Modals

/// `dismiss()` asks whichever router presented this modal to take it down.
struct SplitModalView: View {
    let title: String
    let hostedBy: String

    @Environment(Router<AppRoute>.self) private var router
    @Environment(SplitAppRouter.self) private var splitRouter

    var body: some View {
        List {
            LabeledContent("Hosted by", value: hostedBy)
            Menu("replace — swap this modal's content in place") {
                ForEach(Self.modals, id: \.name) { modal in
                    Button(modal.name == title ? "\(modal.name) — current, no-op" : modal.name) {
                        router.replace(with: .split(modal.route))
                    }
                }
            }
            Button("Dismiss") { router.dismiss() }
            Button("popAllToRoot — clears every surface") {
                splitRouter.popAllToRoot()
            }
        }
        .navigationTitle(title)
    }
}
