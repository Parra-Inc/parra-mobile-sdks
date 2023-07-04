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
    private var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra(state: .initialized)
    }

    override func tearDown() async throws {
        mockParra = nil
    }

    func testEnqueueSync() async throws {
        let notificationExpectation = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager,
            notificationCenter: NotificationCenter.default
        )

        await mockParra.sessionManager.log(event: .init(name: "test"))
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [notificationExpectation], timeout: 1.0)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)
    }

    func testEnqueueSyncWithoutEvents() async throws {
        let syncDidEnd = XCTNSNotificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager,
            notificationCenter: NotificationCenter.default
        )
        syncDidEnd.isInverted = true

        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 1.0)
    }

    func testEnqueueSyncWhileSyncInProgress() async throws {
        let syncDidBegin = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        await mockParra.sessionManager.log(event: .init(name: "test"))
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidBegin], timeout: 1.0)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)

        let syncDidEnd = XCTNSNotificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.expectedFulfillmentCount = 2

        await mockParra.syncManager.enqueueSync(with: .immediate)

        let hasEnqueuedSyncJobs = await mockParra.syncManager.enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        await fulfillment(of: [syncDidEnd], timeout: 30.0)
    }
}
