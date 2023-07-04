//
//  UIDevice.swift
//  Parra
//
//  Created by Mick MacCallum on 6/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

internal extension UIDevice {
    static var modelCode: String {
        if let simulatorModelIdentifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return "Simulator \(simulatorModelIdentifier)"
        }
        var systemInfo = utsname()

        uname(&systemInfo)

        return withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in String(cString: UnsafeRawPointer(ptr).assumingMemoryBound(to: CChar.self))
        }
    }
}

extension UIDevice.BatteryState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
    }
}
