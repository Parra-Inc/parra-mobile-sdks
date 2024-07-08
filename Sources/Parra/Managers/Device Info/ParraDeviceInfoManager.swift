//
//  ParraDeviceInfoManager.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public final class ParraDeviceInfoManager: ObservableObject {
    // MARK: - Internal

    enum Constant {
        static let deviceIdKey = "device_id"
    }

    struct DeviceIdWrapper: Codable {
        let deviceId: String
    }

    private(set) static var current: DeviceInfo = {
        do {
            let info = try ParraDeviceInfoManager.getDeviceInfo(
                from: .current,
                with: ParraDeviceInfoManager.getDeviceId()
            )

            return info
        } catch {
            let message = "Error extracting device id"

            Logger.fatal(message, error)

            fatalError(message)
        }
    }()

    static func getDeviceId() throws -> String {
        let storage = KeychainStorage(
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        if let existing: DeviceIdWrapper = try storage.read(
            name: Constant.deviceIdKey
        ) {
            return existing.deviceId
        }

        let newId = DeviceIdWrapper(
            deviceId: .uuid
        )

        try storage.write(
            name: Constant.deviceIdKey,
            value: newId
        )

        return newId.deviceId
    }

    // MARK: - Private

    private static func getDeviceInfo(
        from device: UIDevice,
        with id: String
    ) -> DeviceInfo {
        return DeviceInfo(
            id: id,
            device: device
        )
    }
}
