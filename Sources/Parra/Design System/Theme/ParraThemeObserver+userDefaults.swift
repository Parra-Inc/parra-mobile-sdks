//
//  ParraThemeObserver+userDefaults.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - ParraThemeObserver.ThemeOptions

extension ParraThemeObserver {
    struct ThemeOptions: Codable, Equatable {
        // MARK: - Lifecycle

        init(preferredColorScheme: ColorScheme?) {
            self.preferredColorScheme = preferredColorScheme
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(
                keyedBy: CodingKeys.self
            )

            let optionId = try container.decodeIfPresent(
                Int.self,
                forKey: .preferredColorScheme
            )

            self.preferredColorScheme = ColorScheme(optionId: optionId)
        }

        // MARK: - Public

        public enum CodingKeys: String, CodingKey {
            case preferredColorScheme
        }

        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(
                keyedBy: CodingKeys.self
            )

            try container.encodeIfPresent(
                preferredColorScheme?.optionId,
                forKey: .preferredColorScheme
            )
        }

        // MARK: - Internal

        let preferredColorScheme: ColorScheme?
    }
}

private extension ColorScheme {
    init?(optionId: Int?) {
        switch optionId {
        case 1:
            self = .light
        case 2:
            self = .dark
        default:
            return nil
        }
    }

    var optionId: Int? {
        switch self {
        case .light:
            return 1
        case .dark:
            return 2
        default:
            return nil
        }
    }
}
