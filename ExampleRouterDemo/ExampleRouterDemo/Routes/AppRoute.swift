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
    case search(SearchRoute)
    case profile(ProfileRoute)
    case deepLinks(DeepLinksRoute)

    func destination() -> some View {
        switch self {
        case let .home(route): route.destination()
        case let .search(route): route.destination()
        case let .profile(route): route.destination()
        case let .deepLinks(route): route.destination()
        }
    }
}

typealias AppRouter = Router<AppRoute>

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

enum SearchRoute: Routable {
    case search
    case results(String)

    func destination() -> some View {
        switch self {
        case .search: SearchView()
        case let .results(query): SearchResultsView(query: query)
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

enum DeepLinksRoute: Routable {
    case deepLinks

    func destination() -> some View {
        switch self {
        case .deepLinks: DeepLinksView()
        }
    }
}
