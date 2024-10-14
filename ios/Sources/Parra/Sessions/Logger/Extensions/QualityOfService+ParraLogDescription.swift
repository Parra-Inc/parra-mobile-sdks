//
//  QualityOfService+ParraLogDescription.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension QualityOfService: ParraLogStringConvertible {
    var loggerDescription: String {
        switch self {
        case .background:
            return "background"
        case .utility:
            return "utility"
        case .default:
            return "default"
        case .userInitiated:
            return "user_initiated"
        case .userInteractive:
            return "user_interactive"
        default:
            return "unknown"
        }
    }
}
