//
//  ParraThemeObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Combine
import SwiftUI

private let logger = Logger(category: "Parra Theme Observer")

@MainActor
/// Listens for changes to the configured ParraTheme and provides a @Published
/// property ``ParraThemeObserver/theme`` to obtain the current theme options
/// and color palette.
public class ParraThemeObserver: ObservableObject {
    // MARK: - Lifecycle

    init(
        theme: ParraTheme,
        notificationCenter: NotificationCenterType
    ) {
        self.theme = theme
        self.notificationCenter = notificationCenter

        if let options = themeOptionsCache.read() {
            self.preferredAppearance = switch options.preferredColorScheme {
            case .light:
                .light
            case .dark:
                .dark
            default:
                .system
            }
        } else {
            self.preferredAppearance = .system
        }

        // Set the default
        self.preferredColorScheme = preferredAppearance.colorScheme

        self.themeWillChangeObserver = addThemeWillChangeObserver(
            with: notificationCenter
        )

        $preferredAppearance
            .sink(receiveValue: onReceiveAppearanceChange)
            .store(in: &appearanceChangeBag)
    }

    deinit {
        if let themeWillChangeObserver {
            notificationCenter.removeObserver(themeWillChangeObserver)
        }
    }

    // MARK: - Public

    /// A color palette representative of the configured ``ParraTheme``. If a
    /// dark mode palette was provided, this will automatically update to
    /// provide those colors when the system appearance changes.
    @Published public var theme: ParraTheme

    /// The user's preference for whether the app should render in light, dark,
    /// or system appearance mode. By default, this will be ``system``,
    /// indicating that the default system light/dark mode preference will be
    /// used.
    @Published public var preferredAppearance: ParraAppearance

    // MARK: - Internal

    enum Constant {
        static let themeOptionsKey = "theme_options"
    }

    let themeOptionsCache = ParraUserDefaultsStorageModule<ThemeOptions>(
        key: Constant.themeOptionsKey,
        jsonEncoder: .parraEncoder,
        jsonDecoder: .parraDecoder
    )

    let notificationCenter: NotificationCenterType

    @Published var preferredColorScheme: ColorScheme?

    var themeWillChangeObserver: NSObjectProtocol?

    // MARK: - Private

    private var appearanceChangeBag = Set<AnyCancellable>()

    private func onReceiveAppearanceChange(
        _ appearance: ParraAppearance
    ) {
        let userInfo = makeNotificationUserInfo(
            from: preferredAppearance.colorScheme,
            to: appearance.colorScheme
        )

        do {
            try themeOptionsCache.write(
                value: ThemeOptions(
                    preferredColorScheme: appearance.colorScheme
                )
            )

            withAnimation { [self] in
                preferredColorScheme = appearance.colorScheme
            } completion: { [self] in
                notificationCenter.post(
                    name: Parra.preferredAppearanceDidChangeNotification,
                    object: nil,
                    userInfo: userInfo
                )
            }
        } catch {
            Logger.error(
                "Error processing preferred app appearance change",
                error
            )
        }
    }

    private func makeNotificationUserInfo(
        from oldPreferredColorScheme: ColorScheme?,
        to newPreferredColorScheme: ColorScheme?
    ) -> [String: Any] {
        var userInfo = [String: Any]()

        if let oldPreferredColorScheme = preferredAppearance.colorScheme {
            userInfo["oldPreferredColorScheme"] = oldPreferredColorScheme
        }

        if let newPreferredColorScheme {
            userInfo["newPreferredColorScheme"] = newPreferredColorScheme
        }

        return userInfo
    }
}
