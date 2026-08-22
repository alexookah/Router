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
}

typealias AppRouter = Router<AppRoute>
typealias SplitAppRouter = SplitRouter<AppRoute>

// MARK: - Per-Feature Routes

enum HomeRoute: Routable {
    case home
    case detail(String)
    case settings

    func destination() -> some View {
        switch self {
        case .home: HomeView()
        case let .detail(id): DetailView(id: id)
        case .settings: SettingsView()
        }
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
            EmptyView()
        }
    }
}
