//
//  ParraAppEnvironment.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public enum ParraAppEnvironment {
    public enum Environment {
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

    public static let isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()

    public static let isBeta: Bool = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"

    public static let isParraDemoBeta: Bool = isBeta && ParraInternal
        .isBundleIdDemoApp()

    public static let isDebugParraDevApp: Bool = isDebug && ParraInternal
        .isBundleIdDevApp()

    public static let shouldAllowDebugLogger: Bool = isDebug || isBeta

    public static let isProduction: Bool = !isDebug && !isBeta

    public static let appConfiguration: Environment = {
        if isDebug {
            return .debug
        } else if isBeta {
            return .beta
        } else {
            return .production
        }
    }()
}
