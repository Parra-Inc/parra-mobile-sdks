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
@usableFromInline
internal enum ParraInternalEvent: ParraDataEvent {
    case appStateChanged
    case batteryLevelChanged
    case batteryStateChanged
    case diskSpaceLow
    case httpRequest(request: URLRequest, response: HTTPURLResponse)
    case keyboardDidHide
    case keyboardDidShow
    case memoryWarning
    case orientationChanged
    case powerStateChanged
    case screenshotTaken
    case significantTimeChange
    case thermalStateChanged

    // MUST all be snake_case. Internal events are allowed to skip automatic conversion.
    @usableFromInline
    var name: String {
        switch self {
        case .appStateChanged:
            return "app_state_changed"
        case .batteryLevelChanged:
            return "battery_level_changed"
        case .batteryStateChanged:
            return "battery_state_changed"
        case .diskSpaceLow:
            return "disk_space_low"
        case .httpRequest:
            return "http_request"
        case .keyboardDidHide:
            return "keyboard_did_hide"
        case .keyboardDidShow:
            return "keyboard_did_show"
        case .memoryWarning:
            return "memory_warning"
        case .orientationChanged:
            return "orientation_changed"
        case .powerStateChanged:
            return "power_state_changed"
        case .screenshotTaken:
            return "screenshot_taken"
        case .significantTimeChange:
            return "significant_time_change"
        case .thermalStateChanged:
            return "thermal_state_changed"
        }
    }

    @usableFromInline
    var extra: [String : Any] {
        switch self {
        case .httpRequest(let request, let response):
            return [
                "request": request.sanitized.dictionary,
                "response": response.sanitized.dictionary,
            ]
        default:
            return [:]
        }
    }
}
