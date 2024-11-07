//
//  AppNavigationState.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/07/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import SwiftUI
import Parra

private let logger = ParraLogger()

// Deep link definitions live in your app's code and not within Parra. This
// gives you the flexibility to support arbitrary combinations of screens
// provided both by Parra and your own code. We provide some defaults based on
// the code in the template.
enum DeepLink: String {
    case appTab = "/app-tab"
    case profileTab = "/profile-tab"
    case notificationSettings = "/profile-tab/notification-settings"

    static let host = "links"

    var fullUrl: URL {
        // As defined in the Info.plist, under `CFBundleURLSchemes`.
        let scheme = "parra-demo"

        return URL(string: "\(scheme)://\(DeepLink.host)/\(rawValue)")!
    }
}

@Observable
class AppNavigationState: ObservableObject {
    enum Tab: Hashable {
        case app
        case profile
    }

    private init() {}

    static let shared = AppNavigationState()

    var selectedTab: Tab = .app
    var appTabNavigationPath: NavigationPath = NavigationPath()
    var profileTabNavigationPath: NavigationPath = NavigationPath()

    @discardableResult
    func handleOpenedUrl(_ url: URL) -> Bool {
        let components = URLComponents(
            url: url,
            resolvingAgainstBaseURL: true
        )

        if let path = components?.path,
           let deepLink = DeepLink(rawValue: path),
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
        logger.info("Opening deep link: \(deepLink.rawValue)")

        switch deepLink {
        case .appTab:
            selectedTab = .app
            appTabNavigationPath = NavigationPath()
        case .profileTab:
            selectedTab = .profile
            profileTabNavigationPath = NavigationPath()
        case .notificationSettings:
            selectedTab = .profile
            profileTabNavigationPath.append(deepLink.rawValue)
        }
    }
}
