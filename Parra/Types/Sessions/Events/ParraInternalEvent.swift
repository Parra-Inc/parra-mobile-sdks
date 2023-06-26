//
//  ParraInternalEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

/// Events that should only be generated from within the Parra SDK. Events that can be generated
/// either in or outside of the SDK, should use the `ParraEvent` type.
internal enum ParraInternalEvent: ParraEvent {
    case appStateChanged(state: UIApplication.State)
    case httpRequest
    case keyboardDidHide
    case keyboardDidShow
    case log
    case memoryWarning
    case orientationChanged
    case screenshotTaken

    var name: String {
        switch self {
        case .appStateChanged(let state):
            return "app_state_changed:\(state)"
        case .httpRequest:
            return "http_request"
        case .keyboardDidHide:
            return "keyboard_did_hide"
        case .keyboardDidShow:
            return "keyboard_did_show"
        case .log:
            return "log"
        case .memoryWarning:
            return "memory_warning"
        case .orientationChanged:
            return "orientation_changed"
        case .screenshotTaken:
            return "screenshot_taken"
        }
    }

    public var params: [String : Any] {
        return [:]
    }
}
