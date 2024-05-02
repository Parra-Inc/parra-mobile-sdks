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
    let mockApiResourceServer: MockResourceServer<ApiResourceServer>
    let mockAuthServer: MockResourceServer<AuthServer>
    let mockExternalResource: MockResourceServer<ExternalResourceServer>

    let dataManager: DataManager
    let syncManager: ParraSyncManager
    let sessionManager: ParraSessionManager
    let apiResourceServer: ApiResourceServer
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
        mockApiResourceServer.urlSession.resetExpectations()
        mockAuthServer.urlSession.resetExpectations()
        mockExternalResource.urlSession.resetExpectations()
    }
}
