//
//  UIDeviceOrientation.swift
//  Parra
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

extension UIDeviceOrientation: ParraLogStringConvertible, CustomStringConvertible {
    public var loggerDescription: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portrait_upside_down"
        case .landscapeLeft:
            return "landscape_left"
        case .landscapeRight:
            return "landscape_right"
        case .faceUp:
            return "face_up"
        case .faceDown:
            return "face_down"
        case .unknown:
            fallthrough
        default:
            return "unknown"
        }
    }

    public var description: String {
        return loggerDescription
    }
}
