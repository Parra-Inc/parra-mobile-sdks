//
//  ParraConfigState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal actor ParraConfigState {
    private var currentState: ParraConfiguration = .default

    internal init() {
        self.currentState = .default
    }

    internal init(currentState: ParraConfiguration) {
        self.currentState = currentState
    }

    internal func getCurrentState() -> ParraConfiguration {
        return currentState
    }

    internal func updateState(_ newValue: ParraConfiguration) {
        currentState = newValue

        ParraDefaultLogger.logQueue.async {
            ParraDefaultLogger.default.loggerConfig = newValue.loggerConfig
        }

        if newValue.pushNotificationsEnabled {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    internal func resetState() {
        currentState = .default
    }
}
