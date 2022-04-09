//
//  ParraSyncManagerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import ParraCore

class ParraSyncManagerTests: XCTestCase {

    func testEnqueueSync() async throws {
        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
        
        expectation(forNotification: Parra.syncDidBeginNotification, object: nil)
        
        await Parra.shared.syncManager.enqueueSync(with: .immediate)

        await waitForExpectations(timeout: 0.1)
        
        let isSyncing = await Parra.shared.syncManager.isSyncing
        XCTAssertTrue(isSyncing)

        let hasEnqueuedSyncJobs = await Parra.shared.syncManager.hasEnqueuedSyncJobs
        XCTAssertFalse(hasEnqueuedSyncJobs)
    }

    func testEnqueueSyncWhileSyncInProgress() async throws {
        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
        
        expectation(forNotification: Parra.syncDidBeginNotification, object: nil)
        await Parra.shared.syncManager.enqueueSync(with: .immediate)
        await waitForExpectations(timeout: 0.1)
        
        let isSyncing = await Parra.shared.syncManager.isSyncing
        XCTAssertTrue(isSyncing)
        
        await Parra.shared.syncManager.enqueueSync(with: .immediate)
        
        let hasEnqueuedSyncJobs = await Parra.shared.syncManager.hasEnqueuedSyncJobs
        XCTAssertTrue(hasEnqueuedSyncJobs)
    }

    private func configureWithRequestResolver(resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)) {
        let dataManager = ParraDataManager()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession(dataTaskResolver: resolver)
        )
        
        let syncManager = ParraFeedbackSyncManager(
            networkManager: networkManager
        )
        
        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
        
        Parra.registerModule(module: FakeModule())
    }
}
