//
//  ParraDeviceAttributeProvider.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/27/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit
import Combine

internal struct ParraDeviceAttributes: ParraAttributes {
    // User defined device name on iOS < 16
    let name: String
    let model: String
    let systemName: String
    let systemVersion: String

    let orientation: String

    // carrier, ip, reachabiliy, https://github.com/DataDog/dd-sdk-ios/blob/3fce96be274e62014687a6c83ef7dd3f15a52391/Sources/Datadog/Core/System/NetworkConnectionInfoProvider.swift
}

class ParraDeviceAttributeProvider: ParraAttributeProvider {
    private static let device = UIDevice.current

    static func getAttributes() -> ParraAttributes {
        return ParraDeviceAttributes(
            name: device.name,
            model: device.model,
            systemName: device.systemName,
            systemVersion: device.systemVersion,
            orientation: device.orientation.description
        )
    }
}
