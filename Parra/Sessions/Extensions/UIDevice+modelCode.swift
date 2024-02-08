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
        if let simulatorModelIdentifier = ProcessInfo()
            .environment["SIMULATOR_MODEL_IDENTIFIER"]
        {
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
}
