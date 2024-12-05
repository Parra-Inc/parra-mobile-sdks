//
//  UIDevice+modelCode.swift
//  Parra
//
//  Created by Mick MacCallum on 6/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIDevice {
    static var modelCode: String {
        if let simulatorModelIdentifier = ProcessInfo.processInfo.environment[
            "SIMULATOR_MODEL_IDENTIFIER"
        ] {
            return "Simulator \(simulatorModelIdentifier)"
        }

        var systemInfo = utsname()
        uname(&systemInfo)

        return withUnsafeMutablePointer(to: &systemInfo.machine) {
            ptr in
            String(
                cString: UnsafeRawPointer(ptr)
                    .assumingMemoryBound(to: CChar.self)
            )
        }
    }

    static let isPreview: Bool = {
        #if targetEnvironment(simulator)
        guard let flag = ProcessInfo.processInfo.environment[
            "XCODE_RUNNING_FOR_PREVIEWS"
        ] else {
            return false
        }

        return flag == "1"
        #else
        return false
        #endif
    }()
}
