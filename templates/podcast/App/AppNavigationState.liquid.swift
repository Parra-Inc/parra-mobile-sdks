//
//  AppNavigationState.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import Parra

private let logger = ParraLogger()

// Deep link definitions live in your app's code and not within Parra. This
// gives you the flexibility to support arbitrary combinations of screens
// provided both by Parra and your own code. We provide some defaults based on
// the code in the template.
enum DeepLink {
    case sampleTab(String?)
    case videosTab(String?)
    case episodesTab(String?)
    case shopTab(String?)
    case settingsTab(String?)

    static let host = "links"

    init?(path: String) {
        let components = path.split(separator: "/")

        guard let first = components.first else {
            return nil
        }

        let remainingComponents = components.dropFirst()
        let otherComponents: String? = if remainingComponents.isEmpty {
            nil
        } else {
            remainingComponents.joined(
                separator: "/"
            )
        }

        switch first {
        case "sample":
            self = .sampleTab(otherComponents)
        case "videos":
            self = .videosTab(otherComponents)
        case "episodes":
            self = .episodesTab(otherComponents)
        case "shop":
            self = .shopTab(otherComponents)
        case "settings":
            self = .settingsTab(otherComponents)
        default:
            return nil
        }
    }

    var fullUrl: URL {
        // As defined in the Info.plist, under `CFBundleURLSchemes`.
        let scheme = Bundle.main.bundleIdentifier!

        let path = switch self {
        case .sampleTab(let path):
            if let path {
                "sample/\(path)"
            } else {
                "sample"
            }
        case .videosTab(let path):
            if let path {
                "videos/\(path)"
            } else {
                "videos"
            }
        case .episodesTab(let path):
            if let path {
                "episodes/\(path)"
            } else {
                "episodes"
            }
        case .shopTab(let path):
            if let path {
                "shop/\(path)"
            } else {
                "shop"
            }
        case .settingsTab(let path):
            if let path {
                "settings/\(path)"
            } else {
                "settings"
            }
        }

        return URL(string: "\(scheme)://\(DeepLink.host)/\(path)")!
    }
}

@Observable
class AppNavigationState {
    enum Tab: Hashable {
        case sample
        case videos
        case episodes
        case shop
        case settings
    }

    private init() {}

    static let shared = AppNavigationState()

    var selectedTab: Tab = .sample
    var sampleNavigationPath = NavigationPath()
    var videosNavigationPath = NavigationPath()
    var episodesNavigationPath = NavigationPath()
    var shopNavigationPath = NavigationPath()
    var settingsNavigationPath = NavigationPath()

    @discardableResult
    func handleOpenedUrl(_ url: URL) -> Bool {
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )

        if let path = components?.path,
           let deepLink = DeepLink(path: path),
           components?.host == DeepLink.host {

            handleDeepLink(deepLink)

            return true
        }

        logger.warn("Link was not handled as deep link", [
            "url": url.absoluteString
        ])

        return false
    }

    func handleDeepLink(_ deepLink: DeepLink) {
        logger.info("Opening deep link: \(deepLink.fullUrl.absoluteString)")

        switch deepLink {
        case .sampleTab(let path):
            selectedTab = .sample
            updateNavigationPath(&sampleNavigationPath, path: path)

        case .videosTab(let path):
            selectedTab = .videos
            updateNavigationPath(&videosNavigationPath, path: path)

        case .episodesTab(let path):
            selectedTab = .episodes
            updateNavigationPath(&episodesNavigationPath, path: path)

        case .shopTab(let path):
            selectedTab = .shop
            updateNavigationPath(&shopNavigationPath, path: path)

        case .settingsTab(let path):
            selectedTab = .settings
            updateNavigationPath(&settingsNavigationPath, path: path)
        }
    }

    private func updateNavigationPath(
        _ navigationPath: inout NavigationPath,
        path: String?
    ) {
        navigationPath.removeLast(navigationPath.count)

        if let path {
            navigationPath = NavigationPath([path])
        } else {
            navigationPath = NavigationPath()
        }
    }
}
