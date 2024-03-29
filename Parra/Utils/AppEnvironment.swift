//
//  AppEnvironment.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum AppEnvironment {
    enum Environment {
        case production
        case beta
        case debug

        // MARK: - Internal

        var headerName: String {
            // Used in API which should be considered before changing!
            switch self {
            case .production:
                return "production"
            case .beta:
                return "beta"
            case .debug:
                return "debug"
            }
        }
    }

    static let isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    static let isBeta: Bool = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"

    static let isParraDemoBeta: Bool = isBeta && ParraInternal
        .isBundleIdDemoApp()

    static let isProduction: Bool = !isDebug && !isBeta

    static let appConfiguration: Environment = {
        if isDebug {
            return .debug
        } else if isBeta {
            return .beta
        } else {
            return .production
        }
    }()
}
