//
//  ProcessInfoThermalState+ParraLogStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ProcessInfo.ThermalState: ParraLogStringConvertible, CustomStringConvertible {
    var loggerDescription: String {
        switch self {
        case .nominal:
            return "nominal"
        case .fair:
            return "fair"
        case .serious:
            return "serious"
        case .critical:
            return "critical"
        default:
            return "unknown"
        }
    }

    public var description: String {
        return loggerDescription
    }
}
