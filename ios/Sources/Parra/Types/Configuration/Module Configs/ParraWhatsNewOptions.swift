//
//  ParraWhatsNewOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

/// Options for how the Parra Release modal should be displayed. I
public struct ParraWhatsNewOptions: ParraConfigurationOptionType {
    // MARK: - Lifecycle

    public init(
        presentationStyle: PresentationStyle,
        presentationMode: PresentationMode
    ) {
        self.presentationStyle = presentationStyle
        self.presentationMode = presentationMode
    }

    // MARK: - Public

    public enum Behavior: Equatable {
        /// 1. If the app has not been launched before, nothing will be
        ///    displayed
        /// 2. If the app has been launched, the bundle version string from the
        ///    Info.plist will be compared to the latest version string publicly
        ///    available on the App Store. If the version strings are the same,
        ///    nothing will be displayed.
        /// 3. A request will be made to the Parra API to fetch the latest
        ///    release. If one exists and it is different from the last release
        ///    displayed to the user, the What's New screen will be displayed.
        case production

        /// The What's New screen will be displayed if the app has not been
        /// launched before, or of the bundle version short string is different
        /// from the last time the release was presented to the user. This is
        /// still dependent on a release matching the app's bundle version being
        /// returned from the Parra API, but is intented to allow for the
        /// changes to be displayed when a new build is released, and to
        /// continue working if the bundle ID hasn't been added to a production
        /// app in App Store Connect.
        case beta

        /// The What's New screen will not be displayed automatically. It can
        /// still be displayed manually by calling the `fetchLatestRelease()`
        /// method.
        case debug

        // MARK: - Public

        public static var `default`: Behavior {
            switch AppEnvironment.appConfiguration {
            case .production:
                return .production
            case .beta:
                return .beta
            case .debug:
                return .debug
            }
        }
    }

    public enum PresentationStyle: Equatable {
        case toast

        /// Default
        case modal
    }

    public enum PresentationMode: Equatable {
        /// Default. Automatically check if there have been new updates and
        /// present the What's New popup right away.
        /// The logic this follows is as follows:
        case automatic(Behavior)

        /// Automaitcally check if there have been new updates and present the
        /// What's New popup after the provided delay (in seconds).
        /// This follows the same logic as the ``automatic`` mode, but with the
        /// addition of a delay before the What's New screen is presented.
        case delayed(Behavior, TimeInterval)

        /// Parra will not automatically check for updates or display the
        /// What's new popup. When desired, use the
        /// ``Parra/Parra/fetchLatestRelease()`` method to load the latest
        /// release from the Parra API. You can make your own determination
        /// about whether you wish to display it. The result of this method can
        /// be passed to the
        /// ``SwiftUI/View/presentParraRelease(with:config:onDismiss:)``
        /// modifier to display the What's New screen.
        case manual

        // MARK: - Internal

        var delay: TimeInterval {
            switch self {
            case .automatic:
                return 0
            case .delayed(_, let timeInterval):
                return timeInterval
            case .manual:
                return .greatestFiniteMagnitude
            }
        }
    }

    public static let `default`: ParraWhatsNewOptions = .init(
        presentationStyle: .modal,
        presentationMode: .automatic(.default)
    )

    public let presentationStyle: PresentationStyle
    public let presentationMode: PresentationMode
}
