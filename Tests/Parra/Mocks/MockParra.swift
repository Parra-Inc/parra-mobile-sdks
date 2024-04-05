//
//  MockParra.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra
import XCTest

struct MockParra {
    let parra: Parra
    let mockNetworkManager: MockParraNetworkManager

    let dataManager: ParraDataManager
    let syncManager: ParraSyncManager
    let sessionManager: ParraSessionManager
    let networkManager: ParraNetworkManager
    let notificationCenter: ParraNotificationCenter

    let appState: ParraAppState

    func notificationExpectation(
        name: Notification.Name,
        object: Any? = nil
    ) -> XCTNSNotificationExpectation {
        return XCTNSNotificationExpectation(
            name: name,
            object: object,
            notificationCenter: notificationCenter.underlyingNotificationCenter
        )
    }

    func tearDown() async throws {
        mockNetworkManager.urlSession.resetExpectations()
    }
}
