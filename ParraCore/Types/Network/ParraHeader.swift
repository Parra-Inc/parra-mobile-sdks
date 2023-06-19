//
//  ParraHeader.swift
//  ParraCore
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import AdSupport

internal enum ParraHeader {
    static let parraHeaderPrefix = "X-PARRA"

    private var prefixedHeaderName: String {
        "\(ParraHeader.parraHeaderPrefix)-\(name)"
    }

    case appLocale
    case appBundleId
    case debug
    case device
    case deviceId
    case deviceLocale
    case deviceManufacturer
    case deviceTimeZoneAbbreviation
    case deviceTimeZoneOffset
    case moduleVersion(moduleName: String, module: ParraModule)
    case platform
    case platformAgent
    case platformVersion

    var name: String {
        switch self {
            // TODO: Application id (application in parra dashboard)
            // TODO: X-PARRA-PLATFORM-SDK-VERSION when we combine parra modules into one
        case .appLocale:
            return "APP-LOCALE"
        case .appBundleId:
            return "APP-BUNDLE-ID"
        case .debug:
            return "DEBUG"
        case .device:
            return "DEVICE"
        case .deviceId:
            return "DEVICE-ID"
        case .deviceLocale:
            return "DEVICE-LOCALE"
        case .deviceTimeZoneAbbreviation:
            return "DEVICE-TIMEZONE-ABBREVIATION"
        case .deviceTimeZoneOffset:
            return "DEVICE-TIMEZONE-OFFSET"
        case .deviceManufacturer:
            return "DEVICE-MANUFACTURER"
        case .moduleVersion(let moduleName, _):
            return "\(moduleName.uppercased())-VERSION"
        case .platform:
            return "PLATFORM"
        case .platformAgent:
            return "PLATFORM-AGENT"
        case .platformVersion:
            return "PLATFORM-VERSION"
        }
    }

    var currentValue: String? {
        switch self {
        case .appLocale:
            return Locale.preferredLanguages.first
        case .appBundleId:
            return Bundle.main.bundleIdentifier
        case .debug:
#if DEBUG
            return "1"
#else
            return nil
#endif
        case .device:
            return UIDevice.modelCode
        case .deviceId:
            return UIDevice.current.identifierForVendor?.uuidString
        case .deviceLocale:
            return NSLocale.current.languageCode
        case .deviceManufacturer:
            return "Apple"
        case .deviceTimeZoneAbbreviation:
            return TimeZone.current.abbreviation()
        case .deviceTimeZoneOffset:
            return String(TimeZone.current.secondsFromGMT())
        case .moduleVersion(_, let module):
            return type(of: module).libraryVersion()
        case .platform:
            return UIDevice.current.systemName
        case .platformAgent:
            return "parra-ios-swift"
        case .platformVersion:
            return UIDevice.current.systemVersion
        }
    }

    static var headerDictionary: [String: String] {
        let keys: [ParraHeader] = [
            .appLocale, .appBundleId, .debug, .device, .deviceId, .deviceLocale, .deviceManufacturer,
            .deviceTimeZoneAbbreviation, .deviceTimeZoneOffset, .platform, .platformAgent, .platformVersion
        ]

        var headers = [String: String]()

        for key in keys {
            if let value = key.currentValue {
                headers[key.prefixedHeaderName] = value
            }
        }

        for (moduleName, module) in Parra.registeredModules {
            let header = ParraHeader.moduleVersion(
                moduleName: moduleName,
                module: module
            )

            if let value = header.currentValue {
                headers[header.prefixedHeaderName] = value
            }
        }

        let debugString = headers.reduce("\n\n") { partialResult, next in
            return "\(partialResult)\n\(next.key): \(next.value)"
        }

        print("++++++++++++++++++++++++++++++++++++++\n\(debugString)\n\n")

        return headers
    }
}
