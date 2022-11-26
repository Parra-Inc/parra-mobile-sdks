//
//  ParraSessionService.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/19/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation
import UIKit

// Changes rarely. Cases like OS upgrades. Can be captured once per app launch.
internal struct ParraSessionDeviceInfo {
    // User defined device name on iOS < 16
    let name: String
    let model: String
    let systemName: String
    let systemVersion: String
}

// Changes frequently. Can be captured multiple times per session
internal struct ParraSessionDeviceState {
    let orientation: String
}

// A session is a series of events

internal struct ParraSession {
    internal let startDate: Date
    internal private(set) var endDate: Date?

    var isComplete: Bool {
        endDate != nil
    }

    mutating func end() {
        assert(!isComplete, "Attempting to end a session that is already complete")

        endDate = Date()
    }
}

internal struct ParraSessionEvent {
    
}

internal class ParraSessionManager {
    private let dataManager: ParraDataManager
    private let device = UIDevice.current

    internal init(dataManager: ParraDataManager) {
        self.dataManager = dataManager
    }

    internal func startTracking() {
        startObservers()
        // Don't take device state snapshot until after this is called
        device.beginGeneratingDeviceOrientationNotifications()
    }

    internal func stopTracking() {
        device.endGeneratingDeviceOrientationNotifications()
        stopObservers()
    }

//    private func takeDeviceInfoSnapshot() -> ParraSessionDeviceInfo {
//
//        //        device.
//    }
//
//    private func takeDeviceStateSnapshot() -> ParraSessionDeviceInfo {
//
//        //        device.
//    }
}


// MARK: Observers
extension ParraSessionManager {
    fileprivate func startObservers() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main,
            using: didReceiveOrientationChangeNotification(notification:)
        )
    }

    fileprivate func stopObservers() {

    }

    private func didReceiveOrientationChangeNotification(notification: Notification) {
        // TODO: Take device state snapshot
    }
}
