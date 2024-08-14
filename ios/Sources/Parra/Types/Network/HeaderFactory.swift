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
        appState: ParraAppState,
        appConfig: ParraConfiguration,
        headerPrefix: String = "PARRA"
    ) {
        self.appState = appState
        self.appConfig = appConfig
        self.headerPrefix = headerPrefix
    }

    // MARK: - Internal

    let appState: ParraAppState
    let appConfig: ParraConfiguration
    let headerPrefix: String

    // Should be included on **every** HTTP request
    var commonHeaderDictionary: [String: String] {
        return headerDictionary(
            for: [
                .environment, .applicationId, .applicationBundleId, .tenantId,
                .platform, .platformAgent
            ]
        )
    }

    var trackingHeaderDictionary: [String: String] {
        return headerDictionary(
            for: TrackingHeader.allCases
        )
    }

    func prefixedName(for header: TrackingHeader) -> String {
        return "\(headerPrefix)-\(header.name)"
    }

    func currentValue(
        for header: TrackingHeader
    ) -> String? {
        switch header {
        case .applicationId:
            return appState.applicationId
        case .applicationLocale:
            return Locale.preferredLanguages.first
        case .applicationBundleId:
            return appConfig.appInfoOptions.bundleId
        case .applicationBundleVersion:
            return Parra.appBundleVersion()
        case .applicationBundleVersionShort:
            return Parra.appBundleVersionShort()
        case .device:
            return ParraDeviceInfoManager.current.modelCode
        case .deviceId:
            return ParraDeviceInfoManager.current.id
        case .deviceLocale:
            return ParraDeviceInfoManager.current.locale
        case .deviceManufacturer:
            return ParraDeviceInfoManager.current.manufacturer
        case .deviceTimeZoneAbbreviation:
            return ParraDeviceInfoManager.current.timeZoneAbbreviation
        case .deviceTimeZoneOffset:
            return ParraDeviceInfoManager.current.timeZoneOffset
        case .environment:
            return AppEnvironment.appConfiguration.headerName
        case .platform:
            return ParraDeviceInfoManager.current.systemName
        case .platformAgent:
            return "parra-ios-swift"
        case .platformSdkVersion:
            return ParraInternal.libraryVersion
        case .platformVersion:
            return ProcessInfo.processInfo.operatingSystemVersionString
        case .tenantId:
            return appState.tenantId
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
