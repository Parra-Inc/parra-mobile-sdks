//
//  ParraHeader.swift
//  ParraCore
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal enum ParraHeader {
    static let parraHeaderPrefix = "parra"

    case debug
    case moduleVersion(module: String)
    case os
    case osVersion
    case device
    case appLocale
    case deviceLocale
    case timeZoneAbbreviation
    case timeZoneOffset

    var headerName: String {
        switch self {
        case .debug:
            return "debug"
        case .moduleVersion(let module):
            return "\(module.lowercased())-version"
        case .os:
            return "os"
        case .osVersion:
            return "os-version"
        case .device:
            return "device"
        case .appLocale:
            return "app-locale"
        case .deviceLocale:
            return "device-locale"
        case .timeZoneAbbreviation:
            return "timezone-abbreviation"
        case .timeZoneOffset:
            return "timezone-offset"
        }
    }

    var prefixedHeaderName: String { "\(ParraHeader.parraHeaderPrefix)-\(headerName)" }
}
