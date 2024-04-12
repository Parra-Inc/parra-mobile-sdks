//
//  ApiResourceServerTests.swift
//  Tests
//
//  Created by Mick MacCallum on 3/20/22.
//

@testable import Parra
import XCTest

class ApiResourceServerTests: MockedParraTestCase {
    // MARK: - Internal

    override func setUp() async throws {
        try createBaseDirectory()

        mockApiResourceServer = await createMockApiResourceServer {
            return UUID().uuidString
        }
    }

    override func tearDown() async throws {
        mockApiResourceServer = nil

        deleteBaseDirectory()
    }

    func testAuthenticatedRequestFailsWithoutAuthProvider() async throws {
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider(nil)

        let endpoint = ParraEndpoint.postAuthentication(
            tenantId: mockApiResourceServer.appState.tenantId
        )
        let expectation = mockApiResourceServer.urlSession.expectInvocation(
            of: endpoint
        )
        expectation.isInverted = true

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }

        await fulfillment(of: [expectation], timeout: 0.2)
    }

    func testAuthenticatedRequestInvokesAuthProvider() async throws {
        let token = UUID().uuidString
        let endpoint = ParraEndpoint.postAuthentication(
            tenantId: mockApiResourceServer.appState.tenantId
        )
        let authEndpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint
            )

        let authProviderExpectation = XCTestExpectation()
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider { () async throws -> String in
                authProviderExpectation.fulfill()

                return token
            }

        let _: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(
            of: [authProviderExpectation, authEndpointExpectation],
            timeout: 0.2
        )

        let persistedCredential = await mockApiResourceServer.dataManager
            .getCurrentCredential()
        XCTAssertEqual(token, persistedCredential?.token)
    }

    func testThrowingAuthenticationHandlerFailsRequest() async throws {
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider { () async throws -> String in
                throw URLError(.cannotLoadFromNetwork)
            }

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: .getCards
                )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testDoesNotRefreshCredentialWhenOneIsPresent() async throws {
        let token = UUID().uuidString
        let credential = ParraCredential(token: token)

        await mockApiResourceServer.dataManager
            .updateCredential(credential: credential)

        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.isInverted = true
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider { () async throws -> String in
                authProviderExpectation.fulfill()

                return token
            }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: .getCards
                )

        switch response.result {
        case .success:
            await fulfillment(of: [authProviderExpectation], timeout: 0.1)
        case .failure(let error):
            throw error
        }
    }

    func testSendsLibraryVersionHeader() async throws {
        let endpoint = ParraEndpoint
            .postBulkSubmitSessions(
                tenantId: mockApiResourceServer.appState.tenantId
            )

        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                return (request.allHTTPHeaderFields ?? [:]).keys
                    .contains { headerKey in
                        return headerKey == "PARRA-PLATFORM-SDK-VERSION"
                    }
            }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        switch response.result {
        case .success:
            await fulfillment(of: [endpointExpectation], timeout: 0.1)
        case .failure(let error):
            throw error
        }
    }

    func testSendsNoBodyWithGetRequests() async throws {
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                return request.httpBody == nil
            }

        let _: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testSendsBodyWithNonGetRequests() async throws {
        let endpoint = ParraEndpoint.postBulkSubmitSessions(
            tenantId: mockApiResourceServer.appState.tenantId
        )

        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                let encoded = try JSONEncoder.parraEncoder
                    .encode(EmptyRequestObject())

                return request.httpBody == encoded
            }

        let _: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testHandlesNoContentHeader() async throws {
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (204, "{\"key\":\"not empty\"}".data(using: .utf8)!)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)

        switch response.result {
        case .success(let data):
            let jsonEncoder = JSONEncoder.parraEncoder
            jsonEncoder.outputFormatting = []

            XCTAssertEqual(.emptyJsonObject, try! jsonEncoder.encode(data))
        case .failure(let error):
            throw error
        }
    }

    func testClientErrorsFailRequests() async throws {
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (400, .emptyJsonObject)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testServerErrorsFailRequests() async throws {
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (500, .emptyJsonObject)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testReauthenticationSuccess() async throws {
        var isFirstRequest = true
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                times: 2,
                toReturn: {
                    if isFirstRequest {
                        isFirstRequest = false
                        return (401, .emptyJsonObject)
                    }

                    return (200, .emptyJsonObject)
                }
            )

        let authProviderExpectation = XCTestExpectation()
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider { () async throws -> String in
                authProviderExpectation.fulfill()

                return UUID().uuidString
            }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: endpoint
                )

        await fulfillment(
            of: [endpointExpectation, authProviderExpectation],
            timeout: 0.1
        )

        switch response.result {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }

    func testReauthenticationFailure() async throws {
        mockApiResourceServer.apiResourceServer
            .updateAuthenticationProvider { () async throws -> String in
                throw URLError(.networkConnectionLost)
            }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.apiResourceServer
                .performRequest(
                    endpoint: .getCards
                )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testPublicApiKeyAuthentication() async throws {
        let endpoint = ParraEndpoint.postAuthentication(
            tenantId: mockApiResourceServer.appState.tenantId
        )
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    let data = try JSONEncoder.parraEncoder.encode(
                        ParraCredential(token: UUID().uuidString)
                    )

                    return (200, data)
                }
            )

        let _ = try await mockApiResourceServer.apiResourceServer
            .performPublicApiKeyAuthenticationRequest(
                forTenant: mockApiResourceServer.appState.tenantId,
                applicationId: mockApiResourceServer.appState.applicationId,
                apiKeyId: UUID().uuidString,
                userId: UUID().uuidString
            )

        await fulfillment(
            of: [endpointExpectation],
            timeout: 0.1
        )
    }

    // MARK: - Private

    private var mockApiResourceServer: MockApiResourceServer!
}
