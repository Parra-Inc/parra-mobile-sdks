//
//  ParraWhatsNewOptions.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraWhatsNewOptions {
    // MARK: - Public

    public enum PresentationStyle {
        case toast

        /// Default
        case modal
    }

    public enum PresentationMode {
        /// Default. Automatically check if there have been new updates and
        /// present the What's New popup right away.
        case automatic

        /// Automaitcally check if there have been new updates and present the
        /// What's New popup after the provided delay (in seconds).
        case delayed(TimeInterval)

        /// Parra will not automatically check for updates or display the
        /// What's new popup. When desired, use the ``presentParraRelease``
        /// instance method on a SwiftUI view to present the What's New screen.
        case manual
    }

    // MARK: - Internal

    static let `default` = ParraWhatsNewOptions(
        presentationStyle: .modal,
        presentationMode: .automatic
    )

    let presentationStyle: PresentationStyle
    let presentationMode: PresentationMode
}
