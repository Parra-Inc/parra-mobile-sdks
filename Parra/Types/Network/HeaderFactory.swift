//
//  HeaderFactory.swift
//  Parra
//
//  Created by Mick MacCallum on 1/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import AdSupport
import Foundation
import UIKit

struct HeaderFactory {
    // MARK: - Lifecycle

    init(
        headerPrefix: String = "PARRA"
    ) {
        self.headerPrefix = headerPrefix
    }

    // MARK: - Internal

    let headerPrefix: String

    // Should be included on **every** HTTP request
    var commonHeaderDictionary: [String: String] {
        return headerDictionary(
            for: [
                .applicationLocale, .applicationBundleVersion,
                .applicationBundleVersion, .debug, .device, .deviceId,
                .deviceLocale, .deviceManufacturer, .deviceTimeZoneAbbreviation,
                .deviceTimeZoneOffset, .platform, .platformAgent,
                .platformSdkVersion, .platformVersion
            ]
        )
    }

    var trackingHeaderDictionary: [String: String] {
        return headerDictionary(
            for: [
                .applicationLocale, .applicationBundleVersion,
                .applicationBundleVersion, .debug, .device, .deviceId,
                .deviceLocale, .deviceManufacturer, .deviceTimeZoneAbbreviation,
                .deviceTimeZoneOffset, .platform, .platformAgent,
                .platformSdkVersion, .platformVersion
            ]
        )
    }

    func prefixedName(for header: TrackingHeader) -> String {
        return "\(headerPrefix)-\(header.name)"
    }

    func currentValue(
        for header: TrackingHeader
    ) -> String? {
        switch header {
        case .applicationId(let applicationId):
            return applicationId
        case .applicationLocale:
            return Locale.preferredLanguages.first
        case .applicationBundleId(let bundleId):
            return bundleId
        case .applicationBundleVersion:
            return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        case .applicationBundleVersionShort:
            return Bundle.main
                .infoDictionary?["CFBundleShortVersionString"] as? String
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
            return ParraInternal.libraryVersion()
        case .platformVersion:
            return ProcessInfo.processInfo.operatingSystemVersionString
        case .tenantId(let tenantId):
            return tenantId
        }
    }

    func headerDictionary(
        for headers: [TrackingHeader]
    ) -> [String: String] {
        var headerDictionary = [String: String]()

        for header in headers {
            if let value = currentValue(for: header) {
                let name = prefixedName(for: header)

                headerDictionary[name] = value
            }
        }

        return headerDictionary
    }
}

enum TrackingHeader {
    case applicationId(String)
    case applicationLocale
    case applicationBundleVersion
    case applicationBundleVersionShort
    case applicationBundleId(String)
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
    case tenantId(String)

    // MARK: - Internal

    var name: String {
        switch self {
        case .applicationLocale:
            return "APPLICATION-LOCALE"
        case .applicationId:
            return "APPLICATION-ID"
        case .applicationBundleId:
            return "APPLICATION-BUNDLE-ID"
        case .applicationBundleVersion:
            return "APPLICATION-BUNDLE-VERSION"
        case .applicationBundleVersionShort:
            return "APPLICATION-BUNDLE-VERSION-SHORT"
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
        case .tenantId:
            return "TENANT-ID"
        }
    }
}
