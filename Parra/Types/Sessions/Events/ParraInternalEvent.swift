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
    case appStateChanged
    case batteryLevelChanged
    case batteryStateChanged
    case httpRequest // TODO
    case keyboardDidHide
    case keyboardDidShow
    case log // TODO
    case memoryWarning
    case orientationChanged
    case screenshotTaken
    case significantTimeChange

    var name: String {
        switch self {
        case .appStateChanged:
            return "app_state_changed"
        case .batteryLevelChanged:
            return "battery_level_changed"
        case .batteryStateChanged:
            return "battery_state_changed"
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
        case .significantTimeChange:
            return "significant_time_change"
        }
    }

    public var params: [String : Any] {
        return [:]
    }
}
