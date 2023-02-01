//
//  Parra+AuthenticationTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/24/22.
//

import XCTest
@testable import ParraCore

class ParraAuthenticationTests: XCTestCase {

    override func setUp() {
        configureWithRequestResolver { request in
            return (kEmptyJsonObjectData, createTestResponse(route: "whatever"), nil)
        }
    }
    
    func testInitWithDefaultAuthProvider() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.initialize(authProvider: .default(tenantId: "tenant", authProvider: {
            return token
        }))

        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }

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
            authProvider: .publicKey(tenantId: tenantId, apiKeyId: apiKeyId, userIdProvider: {
                authProviderExpectation.fulfill()
                return UUID().uuidString
            })
        )

        let _ = try await Parra.shared.networkManager.authenticationProvider!()

        wait(for: [authProviderExpectation], timeout: 0.1)
    }
    
    func testInitWithDefaultAuthProviderFailure() async throws {
        Parra.initialize(authProvider: .default(tenantId: "tenant", authProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()

            XCTFail()
        } catch {}
    }

    func testInitWithPublicKeyAuthProviderFailure() async throws {
        Parra.initialize(authProvider: .publicKey(tenantId: "", apiKeyId: "", userIdProvider: {
            throw URLError(.badServerResponse)
        }))

        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()

            XCTFail()
        } catch {}
    }

    private func configureWithRequestResolver(resolver: @escaping (_ request: URLRequest) -> (Data?, HTTPURLResponse?, Error?)) {
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
            sessionManager: sessionManager
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager
        )
    }
}
