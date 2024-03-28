//
//  AppEnvironment.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum AppEnvironment {
    // MARK: - Internal

    enum Environment {
        case production
        case beta
        case debug
    }

    static var isDebug: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }

    static var appConfiguration: Environment {
        if isDebug {
            return .debug
        } else if isTestFlight {
            return .beta
        } else {
            return .production
        }
    }

    // MARK: - Private

    private static let isTestFlight = Bundle.main.appStoreReceiptURL?
        .lastPathComponent == "sandboxReceipt"
}
