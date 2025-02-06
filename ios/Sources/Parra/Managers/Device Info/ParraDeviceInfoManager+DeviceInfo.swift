//
//  ParraDeviceInfoManager+DeviceInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public extension ParraDeviceInfoManager {
    struct DeviceInfo: Codable, Equatable, Hashable, Sendable, Identifiable {
        // MARK: - Lifecycle

        init(
            id: String,
            device: UIDevice
        ) {
            self.id = id

            self.systemName = device.systemName
            self.systemVersion = device.systemVersion
            self.modelCode = device.modelCode
            self.manufacturer = "Apple"
            self.timeZoneAbbreviation = TimeZone.current.abbreviation()
            self.timeZoneOffset = String(TimeZone.current.secondsFromGMT())
            self.locale = NSLocale.current.language.languageCode?.identifier
        }

        // MARK: - Public

        public let id: String
        public let systemName: String
        public let systemVersion: String
        public let modelCode: String
        public let manufacturer: String
        public let timeZoneAbbreviation: String?
        public let timeZoneOffset: String
        public let locale: String?
    }
}
