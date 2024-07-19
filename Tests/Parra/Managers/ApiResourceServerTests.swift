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
    }

    override func tearDown() async throws {
        deleteBaseDirectory()
    }

    func testThrowingAuthenticationHandlerFailsRequest() async throws {
        let mockApiResourceServer = await createMockApiResourceServer(
            authenticationProvider: {
                throw URLError(.cannotLoadFromNetwork)
            }
        )

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.isInverted = true
        let token = UUID().uuidString

        let user = ParraUser(
            credential: ParraUser.Credential.basic(token),
            info: ParraUser.Info.validStates()[0]
        )

        let mockApiResourceServer = await createMockApiResourceServer {
            authProviderExpectation.fulfill()

            return token
        }
        await mockApiResourceServer.dataManager.updateCurrentUser(user)

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.postBulkSubmitSessions

        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                return (request.allHTTPHeaderFields ?? [:]).keys
                    .contains { headerKey in
                        return headerKey == "PARRA-PLATFORM-SDK-VERSION"
                    }
            }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                return request.httpBody == nil
            }

        let _: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testSendsBodyWithNonGetRequests() async throws {
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.postBulkSubmitSessions

        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(of: endpoint) { request in

                let encoded = try JSONEncoder.parraEncoder
                    .encode(EmptyRequestObject())

                return request.httpBody == encoded
            }

        let _: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
                    endpoint: endpoint
                )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testHandlesNoContentHeader() async throws {
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (204, "{\"key\":\"not empty\"}".data(using: .utf8)!)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (400, .emptyJsonObject)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let mockApiResourceServer = await createMockApiResourceServer()

        let endpoint = ApiEndpoint.getCards
        let endpointExpectation = mockApiResourceServer.urlSession
            .expectInvocation(
                of: endpoint,
                toReturn: {
                    return (500, .emptyJsonObject)
                }
            )

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let authProviderExpectation = XCTestExpectation()
        let mockApiResourceServer = await createMockApiResourceServer {
            authProviderExpectation.fulfill()

            return UUID().uuidString
        }

        var isFirstRequest = true
        let endpoint = ApiEndpoint.getCards
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

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
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
        let mockApiResourceServer = await createMockApiResourceServer {
            throw URLError(.networkConnectionLost)
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> =
            await mockApiResourceServer.resourceServer
                .hitApiEndpoint(
                    endpoint: .getCards
                )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    // MARK: - Private

    private func createMockApiResourceServer(
        authenticationProvider: @escaping () async throws -> String = {
            return UUID().uuidString
        }
    ) async -> MockResourceServer<ApiResourceServer> {
        let (apiResourceServer, _, _) = await createMockResourceServers(
            authenticationProvider: authenticationProvider,
            dataManager: createMockDataManager()
        )

        return apiResourceServer
    }
}
