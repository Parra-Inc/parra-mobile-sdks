//
//  ParraSyncManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import Parra

// TODO: Audit usage of mockParra.sessionManager.writeEvent. Tests might be invalid
// now that the result isn't awaited.

@MainActor
class ParraSyncManagerTests: XCTestCase {
    private var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra(state: .initialized)
    }

    override func tearDown() async throws {
        mockParra.syncManager.stopSyncTimer()

        if await mockParra.syncManager.syncState.isSyncing() {
            // The test is over. Queued jobs should not be started.
            await mockParra.syncManager.cancelEnqueuedSyncs()

            // If there is still a sync in progress when the test ends, wait for it.
            let syncDidEndExpectation = mockParra.notificationExpectation(
                name: Parra.syncDidEndNotification,
                object: mockParra.syncManager
            )

            await fulfillment(
                of: [syncDidEndExpectation],
                timeout: 5.0
            )
        }

        mockParra = nil
    }

    func testStartingSyncTimerActivatesTimer() async throws {
        mockParra.syncManager.startSyncTimer()

        XCTAssertTrue(mockParra.syncManager.isSyncTimerActive())
    }

    func testStartingSyncTimerTriggersSync() async throws {
        let syncTimerTickedExpectation = expectation(
            description: "Sync started"
        )
        mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        logEventToSession(named: "test")

        let syncDidBeginExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        await fulfillment(
            of: [syncTimerTickedExpectation, syncDidBeginExpectation],
            timeout: mockParra.syncManager.syncDelay + 0.5
        )
    }

    func testStoppingSyncTimerDeactivatesTimer() async throws {
        let syncTimerTickedExpectation = expectation(
            description: "Sync ticked"
        )
        syncTimerTickedExpectation.isInverted = true
        mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        try await Task.sleep(for: 0.2)

        mockParra.syncManager.stopSyncTimer()

        XCTAssertFalse(mockParra.syncManager.isSyncTimerActive())

        // Make sure the timer doesn't still end up firing.
        await fulfillment(
            of: [syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay
        )
    }

    func testSyncNotificationsReceivedInCorrectOrder() async throws {
        let syncBeginExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        syncBeginExpectation.assertForOverFulfill = true
        syncBeginExpectation.expectedFulfillmentCount = 1

        let syncEndExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncEndExpectation.assertForOverFulfill = true
        syncEndExpectation.expectedFulfillmentCount = 1

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        // Enforces that a begin notification is received before an end notification.
        await fulfillment(
            of: [syncBeginExpectation, syncEndExpectation],
            timeout: 5.0,
            enforceOrder: true
        )
    }

    func testEnqueueImmediateSyncNoSyncInProgress() async throws {
        let syncBeginExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncBeginExpectation], timeout: 1.0)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)
    }

    func testEnqueueEventualSyncNoSyncInProgress() async throws {
        let notificationExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .eventual)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertFalse(isSyncing)

        await fulfillment(
            of: [notificationExpectation],
            timeout: mockParra.syncManager.syncDelay + 0.5
        )
    }

    func testEnqueuingSyncStartsStoppedSyncTimer() async throws {
        XCTAssertFalse(mockParra.syncManager.isSyncTimerActive())

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .eventual)

        XCTAssertTrue(mockParra.syncManager.isSyncTimerActive())
    }

    func testEnqueuingSyncWithoutAuthStopsExistingTimer() async throws {
        await mockParra.networkManager.updateAuthenticationProvider(nil)

        let syncTimerTickedExpectation = expectation(
            description: "Sync ticked"
        )
        syncTimerTickedExpectation.isInverted = true
        mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        XCTAssertTrue(mockParra.syncManager.isSyncTimerActive())

        await mockParra.syncManager.enqueueSync(with: .immediate)

        XCTAssertFalse(mockParra.syncManager.isSyncTimerActive())

        await fulfillment(
            of: [syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay
        )
    }

    func testSyncEventsIgnoredWithoutAuthProviderSet() async throws {
        await mockParra.networkManager.updateAuthenticationProvider(nil)

        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.isInverted = true

        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 1.0)
    }

    func testEnqueueSyncSkippedWithoutEvents() async throws {
        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.isInverted = true

        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 1.0)
    }

    func testEnqueueImmediateSyncWhileSyncInProgress() async throws {
        // The behavior here is that a sync is already in progress when another
        // high priority sync event is started. Meaning that the second sync should
        // start as soon as the first one finishes.

        let syncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidBegin], timeout: 1.0)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)

        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.expectedFulfillmentCount = 2

        await mockParra.syncManager.enqueueSync(with: .immediate)

        let hasEnqueuedSyncJobs = await mockParra.syncManager.enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        await fulfillment(
            of: [syncDidEnd],
            timeout: mockParra.syncManager.syncDelay * 1.5
        )
    }

    func testEnqueueEventualSyncWhileSyncInProgress() async throws {
        // The behavior here is that a sync is already in progress when another
        // lower priority sync event is started. Meaning that the second sync should
        // be enqueded to take place the next time the sync timer ticks after the
        // current sync job finishes.

        // 1. Start the timer
        // 2. Trigger an immediate sync
        // 3. Observe that the sync ended before the sync timer ticks
        // 4. Enqueue an eventual sync.
        // 5. Observe that a new sync doesn't begin before the sync timer ticks
        // 6. Sync timer ticks, new sync is started.

        let syncTimerTickedExpectation = expectation(
            description: "Sync timer ticked"
        )
        let syncTimerNotTickedAfterFirstSyncExpectation = expectation(
            description: "Sync timer hasn't ticked after first sync complete"
        )
        syncTimerNotTickedAfterFirstSyncExpectation.isInverted = true

        let syncTimerNotTickedAfterSecondSyncExpectation = expectation(
            description: "Sync timer hasn't ticked after second sync complete"
        )
        syncTimerNotTickedAfterSecondSyncExpectation.isInverted = true

        mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
            syncTimerNotTickedAfterFirstSyncExpectation.fulfill()
            syncTimerNotTickedAfterSecondSyncExpectation.fulfill()
        }

        let firstSyncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(
            of: [firstSyncDidBegin, syncTimerNotTickedAfterFirstSyncExpectation],
            timeout: 0.1
        )

        let secondSyncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        secondSyncDidBegin.isInverted = true

        logEventToSession(named: "test2")
        await mockParra.syncManager.enqueueSync(with: .eventual)

        await fulfillment(
            of: [secondSyncDidBegin, syncTimerNotTickedAfterSecondSyncExpectation],
            timeout: mockParra.syncManager.syncDelay * 0.25
        )

        let secondSyncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )

        let thirdSyncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        thirdSyncDidBegin.isInverted = true

        await fulfillment(
            of: [secondSyncDidEnd, syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay + 2.0
        )

        // At this point, the second sync finished and the sync timer ticked.
        // Now we just wait to make sure a 3rd sync job isn't started, since
        // all sessions should be cleared.

        await fulfillment(
            of: [thirdSyncDidBegin],
            timeout: 1.0
        )
    }

    func testCancelEnqueuedSyncs() async throws {
        let syncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidBegin], timeout: 1.0)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)

        await mockParra.syncManager.enqueueSync(with: .immediate)

        let sync2DidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        sync2DidBegin.isInverted = true

        let hasEnqueuedSyncJobs = await mockParra.syncManager.enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        await mockParra.syncManager.cancelEnqueuedSyncs()

        let hasEnqueuedSyncJobsAfterCancel = await mockParra.syncManager.enqueuedSyncMode != nil
        XCTAssertFalse(hasEnqueuedSyncJobsAfterCancel)

        await fulfillment(
            of: [sync2DidBegin],
            timeout: mockParra.syncManager.syncDelay
        )
    }

    private func logEventToSession(
        named name: String,
        fileId: String = #fileID,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        mockParra.sessionManager.writeEventSync(
            wrappedEvent: .event(
                event: ParraBasicEvent(name: name)
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column
            )
        )
    }
}
