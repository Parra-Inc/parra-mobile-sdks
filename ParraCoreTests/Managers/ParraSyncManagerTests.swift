//
//  ParraSyncManagerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import ParraCore

@MainActor
class ParraSyncManagerTests: XCTestCase {
    override func setUp() async throws {
        configureWithRequestResolver { request in
            return (EmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }

        await Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            return UUID().uuidString
        }))
    }

    override func tearDown() async throws {
        await Parra.deinitialize()
    }

    func testEnqueueSync() async throws {
        let notificationExpectation = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: nil,
            notificationCenter: NotificationCenter.default
        )

        await Parra.shared.sessionManager.logEvent("test", params: [String: Any]())
        await Parra.shared.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [notificationExpectation], timeout: 1.0)

        let isSyncing = await SyncState.shared.isSyncing()
        XCTAssertTrue(isSyncing)

        let hasEnqueuedSyncJobs = await Parra.shared.syncManager.enqueuedSyncMode != nil
        XCTAssertFalse(hasEnqueuedSyncJobs)
    }

    func testEnqueueSyncWhileSyncInProgress() async throws {
        let notificationExpectation = XCTNSNotificationExpectation(
            name: Parra.syncDidBeginNotification,
            object: nil,
            notificationCenter: NotificationCenter.default
        )
        
        await Parra.shared.sessionManager.logEvent("test", params: [String: Any]())
        await Parra.shared.syncManager.enqueueSync(with: .immediate)

        await fulfillment(of: [notificationExpectation], timeout: 1.0)

        let isSyncing = await SyncState.shared.isSyncing()
        XCTAssertTrue(isSyncing)
        
        await Parra.shared.syncManager.enqueueSync(with: .immediate)
        
        let hasEnqueuedSyncJobs = await Parra.shared.syncManager.enqueuedSyncMode != nil
        XCTAssertTrue(hasEnqueuedSyncJobs)
    }

    private func configureWithRequestResolver(
        resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)
    ) {
        let notificationCenter = ParraNotificationCenter.default
        let dataManager = ParraDataManager()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession(dataTaskResolver: resolver)
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            networkManager: networkManager
        )

        let syncManager = ParraSyncManager(
            networkManager: networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager,
            notificationCenter: notificationCenter
        )
    }
}
