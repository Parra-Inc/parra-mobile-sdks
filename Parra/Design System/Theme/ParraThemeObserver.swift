//
//  ParraThemeObserver.swift
//  Parra
//
//  Created by Mick MacCallum on 1/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger(category: "Parra Theme Observer")

@MainActor
/// Listens for changes to the configured ParraTheme and provides a @Published property ``palette``
/// for SwiftUI views to use to respond to theme changes.
class ParraThemeObserver: ObservableObject {
    // MARK: Lifecycle

    init(
        theme: ParraTheme,
        notificationCenter: NotificationCenterType
    ) {
        self.theme = theme
        self.notificationCenter = notificationCenter
        self.themeWillChangeObserver = addThemeWillChangeObserver(
            with: notificationCenter
        )
    }

    deinit {
        if let themeWillChangeObserver {
            notificationCenter.removeObserver(themeWillChangeObserver)
        }
    }

    // MARK: Internal

    /// A color palette representative of the configured ``ParraTheme``. If a dark mode palette was provided,
    /// this will automatically update to provide those colors when the system appearance changes.
    @Published var theme: ParraTheme

    // MARK: Private

    private let notificationCenter: NotificationCenterType

    private var themeWillChangeObserver: NSObjectProtocol!

    private func addThemeWillChangeObserver(
        with notificationCenter: NotificationCenterType
    ) -> NSObjectProtocol {
        return notificationCenter.addObserver(
            forName: Parra.themeWillChangeNotification,
            object: nil,
            queue: .main
        ) { notification in
            logger.info("Received \(notification.name.rawValue)")

            let userInfo = notification.userInfo ?? [:]

            guard let oldTheme = userInfo["oldTheme"] as? ParraTheme,
                  let newTheme = userInfo["newTheme"] as? ParraTheme else
            {
                logger
                    .warn(
                        "oldTheme or newTheme was missing from theme change notification."
                    )

                return
            }

            Task {
                await self.receivedThemeWillChange(
                    from: oldTheme,
                    to: newTheme
                )
            }
        }
    }

    private func receivedThemeWillChange(
        from oldTheme: ParraTheme,
        to newTheme: ParraTheme
    ) {
        withAnimation { [self] in
            theme = newTheme
        } completion: { [self] in
            notificationCenter.post(
                name: Parra.themeDidChangeNotification,
                object: nil,
                userInfo: [
                    "oldTheme": oldTheme,
                    "newTheme": newTheme
                ]
            )
        }
    }
}
