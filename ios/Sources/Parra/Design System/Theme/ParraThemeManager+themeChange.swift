//
//  ParraThemeManager+themeChange.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension ParraThemeManager {
    func addThemeWillChangeObserver(
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
            current = newTheme
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
