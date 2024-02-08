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
enum ParraInternalEvent: ParraDataEvent {
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

    // MARK: Internal

    // MUST all be snake_case. Internal events are allowed to skip automatic conversion.
    @usableFromInline var name: String {
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

    @usableFromInline var extra: [String: Any] {
        switch self {
        case .httpRequest(let request, let response):
            return [
                "request": request.sanitized.dictionary,
                "response": response.sanitized.dictionary
            ]
        default:
            return [:]
        }
    }

    @usableFromInline var displayName: String {
        switch self {
        case .appStateChanged:
            return "app state changed to: \(UIApplication.shared.applicationState.loggerDescription)"
        case .batteryLevelChanged:
            return "battery level changed to: \(UIDevice.current.batteryLevel.formatted(.percent))"
        case .batteryStateChanged:
            return "battery state changed to: \(UIDevice.current.batteryState.loggerDescription)"
        case .diskSpaceLow:
            return "disk space is low"
        case .httpRequest(let request, _):
            guard let method = request.httpMethod,
                  let url = request.url,
                  let scheme = url.scheme else
            {
                return "HTTP request"
            }

            let path = url.pathComponents.dropFirst(1).joined(separator: "/")
            var endpoint = ""
            if let host = url.host(percentEncoded: false) {
                endpoint = "\(scheme)://\(host)/"
            }
            endpoint.append(path)

            return "\(method.uppercased()) \(endpoint)"
        case .keyboardDidHide:
            return "keyboard did hide"
        case .keyboardDidShow:
            return "keyboard did show"
        case .memoryWarning:
            return "received memory warning"
        case .orientationChanged:
            return "orientation changed to: \(UIDevice.current.orientation.loggerDescription)"
        case .powerStateChanged:
            return "power state changed to: \(ProcessInfo.processInfo.powerState.loggerDescription)"
        case .screenshotTaken:
            return "screenshot taken"
        case .significantTimeChange:
            return "significant time change"
        case .thermalStateChanged:
            return "thermal state changed to: \(ProcessInfo.processInfo.thermalState.loggerDescription)"
        }
    }
}
