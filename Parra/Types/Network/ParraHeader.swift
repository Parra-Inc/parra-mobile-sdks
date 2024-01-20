//
//  ParraHeader.swift
//  Parra
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import AdSupport

internal enum ParraHeader {
    static let parraHeaderPrefix = "X-PARRA"

    var prefixedName: String {
        "\(ParraHeader.parraHeaderPrefix)-\(name)"
    }

    case applicationId(String)
    case applicationLocale
    case applicationBundleId
    case debug
    case device
    case deviceId
    case deviceLocale
    case deviceManufacturer
    case deviceTimeZoneAbbreviation
    case deviceTimeZoneOffset
    case platform
    case platformAgent
    case platformSdkVersion
    case platformVersion

    private var name: String {
        switch self {
        case .applicationLocale:
            return "APPLICATION-LOCALE"
        case .applicationId:
            return "APPLICATION-ID"
        case .applicationBundleId:
            return "APPLICATION-BUNDLE-ID"
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
        case .platform:
            return "PLATFORM"
        case .platformAgent:
            return "PLATFORM-AGENT"
        case .platformSdkVersion:
            return "PLATFORM-SDK-VERSION"
        case .platformVersion:
            return "PLATFORM-VERSION"
        }
    }

    var currentValue: String? {
        switch self {
        case .applicationId(let applicationId):
            return applicationId
        case .applicationLocale:
            return Locale.preferredLanguages.first
        case .applicationBundleId:
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
            return NSLocale.current.language.languageCode?.identifier
        case .deviceManufacturer:
            return "Apple"
        case .deviceTimeZoneAbbreviation:
            return TimeZone.current.abbreviation()
        case .deviceTimeZoneOffset:
            return String(TimeZone.current.secondsFromGMT())
        case .platform:
            return UIDevice.current.systemName
        case .platformAgent:
            return "parra-ios-swift"
        case .platformSdkVersion:
            return Parra.libraryVersion()
        case .platformVersion:
            return ProcessInfo.processInfo.operatingSystemVersionString
        }
    }

    static var trackingHeaderDictionary: [String : String] {
        let keys: [ParraHeader] = [
            .applicationLocale, .applicationBundleId, .debug, .device, .deviceId, .deviceLocale,
            .deviceManufacturer, .deviceTimeZoneAbbreviation, .deviceTimeZoneOffset, .platform,
            .platformAgent, .platformSdkVersion, .platformVersion
        ]

        var headers = [String : String]()

        for key in keys {
            if let value = key.currentValue {
                headers[key.prefixedName] = value
            }
        }

        return headers
    }
}
