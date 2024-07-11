//
//  ExceptionHandler+CrashType.swift
//  Parra
//
//  Created by Mick MacCallum on 7/11/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension ExceptionHandler {
    enum CrashType: Int, Codable {
        case signal = 1
        case exception = 2

        // MARK: - Internal

        var description: String {
            switch self {
            case .signal:
                return "signal"
            case .exception:
                return "exception"
            }
        }
    }
}
