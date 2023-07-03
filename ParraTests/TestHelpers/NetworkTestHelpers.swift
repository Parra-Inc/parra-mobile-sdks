//
//  NetworkTestHelpers.swift
//  ParraTests
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation
import XCTest
@testable import Parra

struct MockParraNetworkManager {
    let networkManager: ParraNetworkManager
    let dataManager: MockDataManager
    let urlSession: MockURLSession
    let tenantId: String
    let applicationId: String
}

@MainActor
extension XCTestCase {
    func createMockNetworkManager(
        state: ParraState = .initialized,
        authenticationProvider: @escaping ParraAuthenticationProviderFunction = { () -> String in
            return UUID().uuidString
        }
    ) async -> MockParraNetworkManager {
        let tenantId = UUID().uuidString
        let applicationId = UUID().uuidString

        let dataManager = MockDataManager()
        let urlSession = MockURLSession(testCase: self)
        let configState = ParraConfigState.initialized(
            tenantId: tenantId,
            applicationId: applicationId
        )

        let networkManager = ParraNetworkManager(
            state: state,
            configState: configState,
            dataManager: dataManager,
            urlSession: urlSession
        )

        await networkManager.updateAuthenticationProvider(authenticationProvider)

        return MockParraNetworkManager(
            networkManager: networkManager,
            dataManager: dataManager,
            urlSession: urlSession,
            tenantId: tenantId,
            applicationId: applicationId
        )
    }
//    func createMockedParraInstance() -> Parra {
//
//    }

//    @discardableResult
//    func configureWithRequestResolver(
//        resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)
//    ) async -> (ParraSessionManager, ParraSyncManager) {
//        let notificationCenter = ParraNotificationCenter.default
//        let dataManager = ParraDataManager()
//        let networkManager = ParraNetworkManager(
//            dataManager: dataManager,
//            urlSession: MockURLSession(dataTaskResolver: resolver)
//        )
//
//        let (tenantId, applicationId, authProvider) = Parra.withAuthenticationMiddleware(
//            for: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
//                return UUID().uuidString
//            })
//        ) { _ in }
//
//        var newConfig = ParraConfiguration.default
//        newConfig.setTenantId(tenantId)
//        newConfig.setApplicationId(applicationId)
//
//        await ParraConfigState.shared.updateState(newConfig)
//
//        await networkManager.updateAuthenticationProvider(authProvider)
//
//        let sessionManager = ParraSessionManager(
//            dataManager: dataManager,
//            networkManager: networkManager
//        )
//
//        let syncManager = ParraSyncManager(
//            networkManager: networkManager,
//            sessionManager: sessionManager,
//            notificationCenter: notificationCenter
//        )
//
//        Parra.shared = Parra(
//            dataManager: dataManager,
//            syncManager: syncManager,
//            sessionManager: sessionManager,
//            networkManager: networkManager,
//            notificationCenter: notificationCenter
//        )
//
//        return (sessionManager, syncManager)
//    }

//    @MainActor
//    func configureWithRequestResolverOnly(
//        resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)
//    ) async {
//        let notificationCenter = ParraNotificationCenter.default
//        let dataManager = ParraDataManager()
//        let networkManager = ParraNetworkManager(
//            dataManager: dataManager,
//            urlSession: MockURLSession(dataTaskResolver: resolver)
//        )
//
//        let sessionManager = ParraSessionManager(
//            dataManager: dataManager,
//            networkManager: networkManager
//        )
//
//        let syncManager = ParraSyncManager(
//            networkManager: networkManager,
//            sessionManager: sessionManager,
//            notificationCenter: notificationCenter
//        )
//
//        Parra.shared = Parra(
//            dataManager: dataManager,
//            syncManager: syncManager,
//            sessionManager: sessionManager,
//            networkManager: networkManager,
//            notificationCenter: notificationCenter
//        )
//    }
}

//func createTestResponse(route: String,
//                        statusCode: Int = 200,
//                        additionalHeaders: [String: String] = [:]) -> HTTPURLResponse {
//
//    let url = Parra.InternalConstants.parraApiRoot.appendingPathComponent(route)
//
//    return HTTPURLResponse(
//        url: url,
//        statusCode: statusCode,
//        httpVersion: "HTTP/1.1",
//        headerFields: [:].merging(additionalHeaders) { (_, new) in new }
//    )!
//}
