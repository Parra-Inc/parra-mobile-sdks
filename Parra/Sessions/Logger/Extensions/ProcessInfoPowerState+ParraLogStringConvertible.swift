//
//  ProcessInfoPowerState+ParraLogStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ProcessInfo {
    var powerState: PowerState {
        return isLowPowerModeEnabled ? .lowPowerMode : .normal
    }

    enum PowerState {
        case normal
        case lowPowerMode
    }
}

extension ProcessInfo.PowerState: ParraLogStringConvertible, CustomStringConvertible {
    var loggerDescription: String {
        switch self {
        case .normal:
            return "normal"
        case .lowPowerMode:
            return "low_power_mode"
        }
    }

    var description: String {
        return loggerDescription
    }
}
