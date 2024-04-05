//
//  Parra+AuthenticationTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/24/22.
//

@testable import Parra
import XCTest

class ParraAuthenticationTests: MockedParraTestCase {
    override func setUp() async throws {
        // Setup without initialization
        mockParra = await createMockParra(authenticationProvider: nil)
    }

    @MainActor
    func testInitWithDefaultAuthProvider() async throws {
        let token = UUID().uuidString
        let startAuthProvider = await mockParra.parra.parraInternal
            .networkManager
            .getAuthenticationProvider()

        XCTAssertNil(startAuthProvider)

        await mockParra.parra.parraInternal.initialize(
            with: .default(
                tenantId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                authProvider: {
                    return token
                }
            )
        )

        let endAuthProvider = await mockParra.parra.parraInternal.networkManager
            .getAuthenticationProvider()
        XCTAssertNotNil(endAuthProvider)
    }

    func testInitWithPublicKeyAuthProvider() async throws {
        let authEndpointExpectation = try mockParra.mockNetworkManager
            .urlSession.expectInvocation(
                of: .postAuthentication(
                    tenantId: mockParra.appState.tenantId
                ),
                toReturn: (
                    200,
                    ParraCredential(token: UUID().uuidString)
                )
            )

        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.expectedFulfillmentCount = 2
        await mockParra.parra.parraInternal.initialize(
            with: .publicKey(
                tenantId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    authProviderExpectation.fulfill()
                    return UUID().uuidString
                }
            )
        )

        let _ = try await mockParra.mockNetworkManager.networkManager
            .getAuthenticationProvider()!()

        await fulfillment(
            of: [authEndpointExpectation, authProviderExpectation],
            timeout: 2
        )
    }

    func testInitWithDefaultAuthProviderFailure() async throws {
        await mockParra.parra.parraInternal.initialize(
            with: .default(
                tenantId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                authProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockNetworkManager.networkManager
                .getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }

    func testInitWithPublicKeyAuthProviderFailure() async throws {
        await mockParra.parra.parraInternal.initialize(
            with: .publicKey(
                tenantId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockNetworkManager.networkManager
                .getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }
}
