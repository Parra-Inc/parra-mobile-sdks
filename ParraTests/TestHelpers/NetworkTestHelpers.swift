//
//  NetworkTestHelpers.swift
//  ParraTests
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation
import XCTest
@testable import Parra

@MainActor
extension XCTestCase {
    @discardableResult
    func configureWithRequestResolver(
        resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)
    ) async -> (ParraSessionManager, ParraSyncManager) {
        let notificationCenter = ParraNotificationCenter.default
        let dataManager = ParraDataManager()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession(dataTaskResolver: resolver)
        )

        let (tenantId, applicationId, authProvider) = Parra.withAuthenticationMiddleware(
            for: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
                return UUID().uuidString
            })
        ) { _ in }

        var newConfig = ParraConfiguration.default
        newConfig.setTenantId(tenantId)
        newConfig.setApplicationId(applicationId)

        await ParraConfigState.shared.updateState(newConfig)

        await networkManager.updateAuthenticationProvider(authProvider)

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

        return (sessionManager, syncManager)
    }

    @MainActor
    func configureWithRequestResolverOnly(
        resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)
    ) async {
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

func createTestResponse(route: String,
                        statusCode: Int = 200,
                        additionalHeaders: [String: String] = [:]) -> HTTPURLResponse {

    let url = Parra.InternalConstants.parraApiRoot.appendingPathComponent(route)

    return HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: [:].merging(additionalHeaders) { (_, new) in new }
    )!
}
