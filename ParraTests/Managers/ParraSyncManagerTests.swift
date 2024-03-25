//
//  ParraSyncManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

class ParraSyncManagerTests: MockedParraTestCase {
    // MARK: - Internal

    override func tearDown() async throws {
        await mockParra.syncManager.stopSyncTimer()

        if await mockParra.syncManager.syncState.isSyncing() {
            // The test is over. Queued jobs should not be started.
            mockParra.syncManager.cancelEnqueuedSyncs()

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

        try await super.tearDown()
    }

    func testStartingSyncTimerActivatesTimer() async throws {
        await mockParra.syncManager.startSyncTimer()

        let isActive = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertTrue(isActive)
    }

    func testStartingSyncTimerTriggersSync() async throws {
        let syncTimerTickedExpectation = expectation(
            description: "Sync started"
        )
        // Should fulfill exactly once after call to start sync timer. After
        // that has been awaited, ignore subsequent repeat fulfillments as the
        // timer keeps ticking.
        syncTimerTickedExpectation.assertForOverFulfill = false

        await mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        await fulfillment(
            of: [syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay + 0.2
        )

        let syncDidBeginExpectation = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )

        logEventToSession(named: "test")

        await fulfillment(
            of: [syncDidBeginExpectation],
            timeout: mockParra.syncManager.syncDelay + 5.0
        )
    }

    func testStoppingSyncTimerDeactivatesTimer() async throws {
        let syncTimerTickedExpectation = expectation(
            description: "Sync ticked"
        )
        syncTimerTickedExpectation.isInverted = true
        syncTimerTickedExpectation.assertForOverFulfill = false

        await mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        try await Task.sleep(for: 0.05)

        await mockParra.syncManager.stopSyncTimer()
        let isActive = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertFalse(isActive)

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

        await fulfillment(of: [syncBeginExpectation])

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
        let isActive = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertFalse(isActive)

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .eventual)

        let isActive2 = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertTrue(isActive2)
    }

    func testEnqueuingSyncWithoutAuthStopsExistingTimer() async throws {
        mockParra.networkManager.updateAuthenticationProvider(nil)

        let syncTimerTickedExpectation = expectation(
            description: "Sync ticked"
        )
        syncTimerTickedExpectation.isInverted = true
        syncTimerTickedExpectation.assertForOverFulfill = false

        await mockParra.syncManager.startSyncTimer {
            syncTimerTickedExpectation.fulfill()
        }

        let isActive = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertTrue(isActive)

        await mockParra.syncManager.enqueueSync(with: .immediate)

        let isActive2 = await mockParra.syncManager.isSyncTimerActive()

        XCTAssertFalse(isActive2)

        await fulfillment(
            of: [syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay
        )
    }

    func testSyncEventsIgnoredWithoutAuthProviderSet() async throws {
        mockParra.networkManager.updateAuthenticationProvider(nil)

        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.isInverted = true

        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 0.1)
    }

    func testEnqueueSyncSkippedWithoutEvents() async throws {
        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.isInverted = true

        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidEnd], timeout: 0.1)
    }

    func testEnqueueImmediateSyncWhileSyncInProgress() async throws {
        // The behavior here is that a sync is already in progress when another
        // high priority sync event is started. Meaning that the second sync should
        // start as soon as the first one finishes.

        let syncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        syncDidBegin.assertForOverFulfill = true
        syncDidBegin.expectedFulfillmentCount = 1
        let syncDidEnd = mockParra.notificationExpectation(
            name: Parra.syncDidEndNotification,
            object: mockParra.syncManager
        )
        syncDidEnd.expectedFulfillmentCount = 1

        logEventToSession(named: "test")
        await mockParra.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [syncDidBegin], timeout: 0.1)

        let isSyncing = await mockParra.syncManager.syncState.isSyncing()
        XCTAssertTrue(isSyncing)

        await mockParra.syncManager.enqueueSync(with: .immediate)

        let hasEnqueuedSyncJobs = mockParra.syncManager
            .enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        await fulfillment(
            of: [syncDidEnd],
            timeout: mockParra.syncManager.syncDelay
        )

        let secondSyncDidBegin = mockParra.notificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: mockParra.syncManager
        )
        secondSyncDidBegin.isInverted = true

        // Make sure a 2nd sync does not start.
        await fulfillment(
            of: [secondSyncDidBegin],
            timeout: 1.5
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
        syncTimerTickedExpectation.assertForOverFulfill = false
        let syncTimerNotTickedAfterFirstSyncExpectation = expectation(
            description: "Sync timer hasn't ticked after first sync complete"
        )
        syncTimerNotTickedAfterFirstSyncExpectation.isInverted = true

        let syncTimerNotTickedAfterSecondSyncExpectation = expectation(
            description: "Sync timer hasn't ticked after second sync complete"
        )
        syncTimerNotTickedAfterSecondSyncExpectation.isInverted = true

        await mockParra.syncManager.startSyncTimer {
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
            of: [
                firstSyncDidBegin,
                syncTimerNotTickedAfterFirstSyncExpectation
            ],
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
            of: [
                secondSyncDidBegin,
                syncTimerNotTickedAfterSecondSyncExpectation
            ],
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

        await fulfillment(
            of: [secondSyncDidEnd, syncTimerTickedExpectation],
            timeout: mockParra.syncManager.syncDelay + 2.0
        )

        // At this point, the second sync finished and the sync timer ticked.
        // Now we just wait to make sure a 3rd sync job isn't started, since
        // all sessions should be cleared.
        await fulfillment(
            of: [thirdSyncDidBegin],
            timeout: mockParra.syncManager.syncDelay
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

        let hasEnqueuedSyncJobs = mockParra.syncManager
            .enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)

        mockParra.syncManager.cancelEnqueuedSyncs()

        let hasEnqueuedSyncJobsAfterCancel = mockParra.syncManager
            .enqueuedSyncMode != nil
        XCTAssertFalse(hasEnqueuedSyncJobsAfterCancel)

        await fulfillment(
            of: [sync2DidBegin],
            timeout: mockParra.syncManager.syncDelay
        )
    }

    // MARK: - Private

    private func logEventToSession(
        named name: String,
        fileId: String = #fileID,
        function: String = #function,
        line: Int = #line,
        column: Int = #column
    ) {
        let threadInfo = ParraLoggerThreadInfo(
            thread: .current
        )

        let (event, _) = ParraSessionEvent.sessionEventFromEventWrapper(
            wrappedEvent: .event(
                event: ParraBasicEvent(name: name)
            ),
            callSiteContext: ParraLoggerCallSiteContext(
                fileId: fileId,
                function: function,
                line: line,
                column: column,
                threadInfo: threadInfo
            )
        )

        mockParra.dataManager.sessionStorage.writeEvent(
            event: event,
            context: ParraSessionEventContext(
                isClientGenerated: true,
                syncPriority: .critical
            )
        )
    }
}
