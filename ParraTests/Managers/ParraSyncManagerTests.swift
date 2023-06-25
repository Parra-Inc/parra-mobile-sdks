//
//  ParraSyncManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import Parra

@MainActor
class ParraSyncManagerTests: XCTestCase {
    private var sessionManager: ParraSessionManager!
    private var syncManager: ParraSyncManager!

    override func setUp() async throws {
        let (sessionManager, syncManager) = await configureWithRequestResolver { request in
            if let url = request.url?.absoluteString, url.contains("session") {
                return (
                    try! JSONEncoder.parraEncoder.encode(ParraSessionsResponse(shouldPoll: false, retryDelay: 0, retryTimes: 0)),
                    createTestResponse(route: "whatever"),
                    nil
                )
            }
            return (EmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }

        self.sessionManager = sessionManager
        self.syncManager = syncManager

        await self.sessionManager.clearSessionHistory()
    }

    override func tearDown() async throws {
        await sessionManager.resetSession()

        syncManager = nil
        sessionManager = nil
    }

    func testEnqueueSync() async throws {
        let notificationExpectation = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: syncManager,
            notificationCenter: NotificationCenter.default
        )

        await sessionManager.logEvent("test", params: [String: Any]())
        await syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [notificationExpectation], timeout: 1.0)

        let isSyncing = await SyncState.shared.isSyncing()
        XCTAssertTrue(isSyncing)
    }

    func testEnqueueSyncWithoutEvents() async throws {
        let syncDidEnd = XCTNSNotificationExpectation(
            name: Parra.syncDidEndNotification,
            object: syncManager,
            notificationCenter: NotificationCenter.default
        )
        syncDidEnd.isInverted = true

        await syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 1.0)
    }

    func testEnqueueSyncWhileSyncInProgress() async throws {
        let syncDidBegin = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: syncManager
        )

        await Parra.shared.sessionManager.logEvent("test", params: [String: Any]())
        await Parra.shared.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidBegin], timeout: 1.0)

        let isSyncing = await SyncState.shared.isSyncing()
        XCTAssertTrue(isSyncing)

        let syncDidEnd = XCTNSNotificationExpectation(
            name: Parra.syncDidEndNotification,
            object: syncManager
        )
        syncDidEnd.expectedFulfillmentCount = 2

        await Parra.shared.syncManager.enqueueSync(with: .immediate)

        let hasEnqueuedSyncJobs = await Parra.shared.syncManager.enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        await fulfillment(of: [syncDidEnd], timeout: 30.0)
    }
}
