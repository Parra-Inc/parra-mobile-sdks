//
//  ParraConfigState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

@globalActor
internal struct ParraConfigState {
    internal static let shared = State()

    internal actor State {
        private var currentState: ParraConfiguration = .default

        fileprivate init() {}

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
}
