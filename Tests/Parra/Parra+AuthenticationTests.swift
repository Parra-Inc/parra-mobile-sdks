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
            .apiResourceServer
            .getAuthenticationProvider()

        XCTAssertNil(startAuthProvider)

        await mockParra.parra.parraInternal.initialize(
            with: .default(
                workspaceId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                authProvider: {
                    return token
                }
            )
        )

        let endAuthProvider = await mockParra.parra.parraInternal
            .apiResourceServer
            .getAuthenticationProvider()
        XCTAssertNotNil(endAuthProvider)
    }

    func testInitWithPublicKeyAuthProvider() async throws {
        let authEndpointExpectation = try mockParra.mockApiResourceServer
            .urlSession.expectInvocation(
                of: .postAuthentication(
                    tenantId: mockParra.appState.tenantId
                ),
                toReturn: (
                    200,
                    ParraUser.Credential(token: UUID().uuidString)
                )
            )

        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.expectedFulfillmentCount = 2
        await mockParra.parra.parraInternal.initialize(
            with: .publicKey(
                workspaceId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    authProviderExpectation.fulfill()
                    return UUID().uuidString
                }
            )
        )

        let _ = try await mockParra.mockApiResourceServer.apiResourceServer
            .getAuthenticationProvider()!()

        await fulfillment(
            of: [authEndpointExpectation, authProviderExpectation],
            timeout: 2
        )
    }

    func testInitWithDefaultAuthProviderFailure() async throws {
        await mockParra.parra.parraInternal.initialize(
            with: .default(
                workspaceId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                authProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockApiResourceServer.apiResourceServer
                .getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }

    func testInitWithPublicKeyAuthProviderFailure() async throws {
        await mockParra.parra.parraInternal.initialize(
            with: .publicKey(
                workspaceId: mockParra.appState.tenantId,
                applicationId: mockParra.appState.applicationId,
                apiKeyId: UUID().uuidString,
                userIdProvider: {
                    throw URLError(.badServerResponse)
                }
            )
        )

        do {
            let _ = try await mockParra.mockApiResourceServer.apiResourceServer
                .getAuthenticationProvider()!()

            XCTFail()
        } catch {}
    }
}
