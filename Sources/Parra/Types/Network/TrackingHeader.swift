//
//  TrackingHeader.swift
//  Parra
//
//  Created by Mick MacCallum on 4/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum TrackingHeader: CaseIterable {
    case applicationId
    case applicationLocale
    case applicationBundleVersion
    case applicationBundleVersionShort
    case applicationBundleId
    case device
    case deviceId
    case deviceLocale
    case deviceManufacturer
    case deviceTimeZoneAbbreviation
    case deviceTimeZoneOffset
    case environment
    case platform
    case platformAgent
    case platformSdkVersion
    case platformVersion
    case tenantId

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
        case .environment:
            return "ENVIRONMENT"
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
