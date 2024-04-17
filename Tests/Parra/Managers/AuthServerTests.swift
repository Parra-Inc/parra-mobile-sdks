//
//  AuthServerTests.swift
//  Tests
//
//  Created by Mick MacCallum on 4/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

@testable import Parra
import XCTest

class AuthServerTests: MockedParraTestCase {
    // MARK: - Internal

    override func setUp() async throws {
        try createBaseDirectory()
    }

    override func tearDown() async throws {
        deleteBaseDirectory()
    }

//    func testPublicApiKeyAuthentication() async throws {
//        let mockAuthServer = await createMockAuthServer()
//
//        let endpoint = ParraEndpoint.postAuthentication(
//            tenantId: mockAuthServer.appState.tenantId
//        )
//        let endpointExpectation = mockAuthServer.urlSession
//            .expectInvocation(
//                of: endpoint,
//                toReturn: {
//                    let data = try JSONEncoder.parraEncoder.encode(
//                        ParraUser.Credential(token: UUID().uuidString)
//                    )
//
//                    return (200, data)
//                }
//            )
//
//        let _ = try await mockAuthServer.resourceServer
//            .performPublicApiKeyAuthenticationRequest(
//                forTenant: mockAuthServer.appState.tenantId,
//                apiKeyId: UUID().uuidString,
//                userId: UUID().uuidString
//            )
//
//        await fulfillment(
//            of: [endpointExpectation],
//            timeout: 0.1
//        )
//    }

    // MARK: - Private

    private func createMockAuthServer(
        with authenticationProvider: @escaping () async -> String = {
            return UUID().uuidString
        }
    ) async -> MockResourceServer<AuthServer> {
        let (_, authServer, _) = await createMockResourceServers(
            authenticationProvider: authenticationProvider,
            dataManager: createMockDataManager()
        )

        return authServer
    }
}
