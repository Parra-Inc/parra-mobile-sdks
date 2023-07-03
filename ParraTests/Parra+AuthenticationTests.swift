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
    private var mockParra: MockParra!

    override func setUp() async throws {
        mockParra = await createMockParra()
    }

    override func tearDown() async throws {
        mockParra = nil
    }

    @MainActor
    func testInitWithDefaultAuthProvider() async throws {
        let token = UUID().uuidString
        let startAuthProvider = await mockParra.parra.networkManager.getAuthenticationProvider()
        XCTAssertNil(startAuthProvider)

        await mockParra.parra.initialize(
            options: [],
            authProvider: .default(
                tenantId: mockParra.tenantId,
                applicationId: mockParra.applicationId,
                authProvider: {
                    return token
                }
            )
        )

        let endAuthProvider = await mockParra.parra.networkManager.getAuthenticationProvider()
        XCTAssertNotNil(endAuthProvider)
    }

    func testInitWithPublicKeyAuthProvider() async throws {
        let authEndpointExpectation = try mockParra.mockNetworkManager.urlSession.expectInvocation(
            of: .postAuthentication(tenantId: mockParra.tenantId),
            toReturn: (200, ParraCredential(token: UUID().uuidString))
        )

        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.expectedFulfillmentCount = 2
        await mockParra.parra.initialize(
            authProvider: .publicKey(
                tenantId: mockParra.tenantId,
                applicationId: mockParra.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    authProviderExpectation.fulfill()
                    return UUID().uuidString
                })
        )

        let _ = try await mockParra.mockNetworkManager.networkManager.getAuthenticationProvider()!()

        await fulfillment(
            of: [authEndpointExpectation, authProviderExpectation],
            timeout: 0.2
        )
    }

    func testInitWithDefaultAuthProviderFailure() async throws {
        await mockParra.parra.initialize(
            authProvider: .default(
                tenantId: mockParra.tenantId,
                applicationId: mockParra.applicationId,
                authProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockNetworkManager.networkManager.getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }

    func testInitWithPublicKeyAuthProviderFailure() async throws {
        await mockParra.parra.initialize(
            authProvider: .publicKey(
                tenantId: mockParra.tenantId,
                applicationId: mockParra.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockNetworkManager.networkManager.getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }
}
