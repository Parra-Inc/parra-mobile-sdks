//
//  ParraConfigState.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

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
        }

        internal func resetState() {
            currentState = .default
        }
    }
}
