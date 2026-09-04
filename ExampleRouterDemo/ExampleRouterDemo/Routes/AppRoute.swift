//
//  AppRoute.swift
//  ExampleRouterDemo
//
//  Created by Alexandros Lykesas on 15/4/26.
//

import SwiftUI
import Router

// MARK: - Top-Level Route

enum AppRoute: Routable {
    case home(HomeRoute)
    case profile(ProfileRoute)
    case stacking(StackingRoute)
    case deepLinks(DeepLinksRoute)
    case split(SplitRoute)

    func destination() -> some View {
        switch self {
        case let .home(route): route.destination()
        case let .profile(route): route.destination()
        case let .stacking(route): route.destination()
        case let .deepLinks(route): route.destination()
        case let .split(route): route.destination()
        }
    }

    var ownsNavigation: Bool {
        switch self {
        case let .home(route): route.ownsNavigation
        case let .profile(route): route.ownsNavigation
        case let .stacking(route): route.ownsNavigation
        case let .deepLinks(route): route.ownsNavigation
        case let .split(route): route.ownsNavigation
        }
    }

    var hidesTabBar: Bool {
        switch self {
        case let .home(route): route.hidesTabBar
        case let .profile(route): route.hidesTabBar
        case let .stacking(route): route.hidesTabBar
        case let .deepLinks(route): route.hidesTabBar
        case let .split(route): route.hidesTabBar
        }
    }
}

typealias AppRouter = Router<AppRoute>
typealias SplitAppRouter = SplitRouter<AppRoute>

// MARK: - Per-Feature Routes

enum HomeRoute: Routable {
    case home
    case detail(String)
    case settings
    case swap(Int)
    case share(URL)
    case photoPicker
    case reader

    func destination() -> some View {
        switch self {
        case .home: HomeView()
        case let .detail(id): DetailView(id: id)
        case .settings: SettingsView()
        case let .swap(step): SwapDemoView(step: step)
        case let .share(url): ShareSheetView(items: [url])
        case .photoPicker: PhotoPickerView()
        case .reader: ReaderView()
        }
    }

    /// UIKit controllers that bring their own bar are presented bare.
    var ownsNavigation: Bool {
        switch self {
        case .share, .photoPicker: true
        default: false
        }
    }

    /// Full-height reading: the tab bar goes while it is on top.
    var hidesTabBar: Bool {
        if case .reader = self { true } else { false }
    }
}

enum ProfileRoute: Routable {
    case profile
    case editProfile

    func destination() -> some View {
        switch self {
        case .profile: ProfileView()
        case .editProfile: EditProfileView()
        }
    }
}

enum StackingRoute: Routable {
    case stacking
    case layer(Int)

    func destination() -> some View {
        switch self {
        case .stacking: StackingView()
        case let .layer(depth): LayerView(depth: depth)
        }
    }
}

enum DeepLinksRoute: Routable {
    case deepLinks

    func destination() -> some View {
        switch self {
        case .deepLinks: DeepLinksView()
        }
    }
}

enum SplitRoute: Routable {
    case folders
    case folder(Int)
    case overview
    case article(Int)
    case filters
    case share
    case settings
    case editor
    case nestedSplit

    func destination() -> some View {
        switch self {
        case .folders: SplitFoldersView()
        case let .folder(index): SplitFolderView(index: index)
        case .overview: SplitOverviewView()
        case let .article(index): SplitArticleView(index: index)
        case .filters:
            SplitModalView(title: "Filters", hostedBy: "the sidebar column")
        case .share:
            SplitModalView(title: "Share", hostedBy: "the detail column")
        case .settings:
            SplitModalView(title: "Settings", hostedBy: "the split router")
        case .editor:
            SplitModalView(title: "Editor", hostedBy: "the split router (cover)")
        case .nestedSplit:
            NestedSplitDemoView()
        }
    }

    /// The nested split composes its own `SplitRoutingView`.
    var ownsNavigation: Bool {
        if case .nestedSplit = self { true } else { false }
    }
}
