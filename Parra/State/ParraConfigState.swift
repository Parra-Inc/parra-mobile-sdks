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
    internal static nonisolated let defaultState: ParraConfiguration = .default

    private var currentState: ParraConfiguration = ParraConfigState.defaultState

    internal init() {
        self.currentState = ParraConfigState.defaultState
    }

    internal init(currentState: ParraConfiguration) {
        self.currentState = currentState
    }

    internal func getCurrentState() -> ParraConfiguration {
        return currentState
    }

    // This should ONLY ever happen on initialization. Setting this elsewhere will require
    // consideration for how ParraSessionManager receives its copy of the state.
    internal func updateState(_ newValue: ParraConfiguration) {
        currentState = newValue

        if newValue.pushNotificationsEnabled {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    internal func resetState() {
        currentState = ParraConfigState.defaultState
    }
}
