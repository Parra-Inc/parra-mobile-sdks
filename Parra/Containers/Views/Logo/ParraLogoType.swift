//
//  ParraLogoType.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum ParraLogoType {
    case logo
    case logoAndText
    case poweredBy

    // MARK: - Internal

    var utmMedium: String {
        switch self {
        case .logo:
            return "parra_logo"
        case .logoAndText:
            return "parra_logo_and_text"
        case .poweredBy:
            return "powered_by_parra"
        }
    }
}
