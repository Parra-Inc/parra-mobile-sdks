//
//  Parra+AuthenticationTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/24/22.
//

import XCTest
@testable import ParraCore

@MainActor
class ParraAuthenticationTests: XCTestCase {

    @MainActor
    override func setUp() async throws {
        Parra.Initializer.isInitialized = false

        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
    }
    
    @MainActor
    func testInitWithDefaultAuthProvider() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            return token
        }))

        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }

    @MainActor
    func testInitWithPublicKeyAuthProvider() async throws {
        let dataManager = ParraDataManager()
        let tenantId = UUID().uuidString
        let apiKeyId = UUID().uuidString

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
            sessionManager: sessionManager
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager
        )

        let authProviderExpectation = XCTestExpectation()

        Parra.initialize(
            authProvider: .publicKey(tenantId: tenantId, applicationId: "myapp", apiKeyId: apiKeyId, userIdProvider: {
                authProviderExpectation.fulfill()
                return UUID().uuidString
            }))

        let _ = try await Parra.shared.networkManager.authenticationProvider!()

        await fulfillment(of: [authProviderExpectation], timeout: 0.1)
    }
    
    @MainActor
    func testInitWithDefaultAuthProviderFailure() async throws {
        Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()

            XCTFail()
        } catch {}
    }

    @MainActor
    func testInitWithPublicKeyAuthProviderFailure() async throws {
        Parra.initialize(authProvider: .publicKey(tenantId: "", applicationId: "myapp", apiKeyId: "", userIdProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()

            XCTFail()
        } catch {}
    }
}
