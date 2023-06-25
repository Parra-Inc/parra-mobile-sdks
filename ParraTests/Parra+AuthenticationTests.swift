//
//  Parra+AuthenticationTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/24/22.
//

import XCTest
@testable import Parra

@MainActor
class ParraAuthenticationTests: XCTestCase {

    @MainActor
    override func setUp() async throws {
        await ParraGlobalState.shared.deinitialize()

        await configureWithRequestResolverOnly { request in
            return (EmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
    }
    
    @MainActor
    func testInitWithDefaultAuthProvider() async throws {
        let token = UUID().uuidString
        let startAuthProvider = await Parra.shared.networkManager.getAuthenticationProvider()
        XCTAssertNil(startAuthProvider)

        await Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            return token
        }))

        let endAuthProvider = await Parra.shared.networkManager.getAuthenticationProvider()
        XCTAssertNotNil(endAuthProvider)
    }

    @MainActor
    func testInitWithPublicKeyAuthProvider() async throws {
        let dataManager = ParraDataManager()
        let tenantId = UUID().uuidString
        let apiKeyId = UUID().uuidString

        let notificationCenter = ParraNotificationCenter.default

        let route = "tenants/\(tenantId)/issuers/public/auth/token"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let data = try! JSONEncoder().encode(ParraCredential(token: UUID().uuidString))
                return (data, createTestResponse(route: route), nil)
            }
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

        let authProviderExpectation = XCTestExpectation()

        await Parra.initialize(
            authProvider: .publicKey(tenantId: tenantId, applicationId: "myapp", apiKeyId: apiKeyId, userIdProvider: {
                authProviderExpectation.fulfill()
                return UUID().uuidString
            }))

        let _ = try await Parra.shared.networkManager.getAuthenticationProvider()!()

        await fulfillment(of: [authProviderExpectation], timeout: 0.1)
    }
    
    @MainActor
    func testInitWithDefaultAuthProviderFailure() async throws {
        await Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }

    @MainActor
    func testInitWithPublicKeyAuthProviderFailure() async throws {
        await Parra.initialize(authProvider: .publicKey(tenantId: "", applicationId: "myapp", apiKeyId: "", userIdProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }
}
