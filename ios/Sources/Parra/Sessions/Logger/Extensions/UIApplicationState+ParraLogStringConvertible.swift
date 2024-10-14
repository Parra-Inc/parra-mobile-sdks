//
//  UIApplicationState+ParraLogStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 1/19/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit

extension UIApplication.State: ParraLogStringConvertible {
    public var loggerDescription: String {
        switch self {
        case .active:
            return "active"
        case .inactive:
            return "inactive"
        case .background:
            return "background"
        @unknown default:
            return "unknown"
        }
    }
}
