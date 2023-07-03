//
//  ParraNetworkManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import Parra

@MainActor
class ParraNetworkManagerTests: XCTestCase {
    private var mockNetworkManager: MockParraNetworkManager!

    override func setUp() async throws {
        mockNetworkManager = await createMockNetworkManager()
    }

    override func tearDown() async throws {
        mockNetworkManager = nil
    }

    func testAuthenticatedRequestFailsWithoutAuthProvider() async throws {
        await mockNetworkManager.networkManager.updateAuthenticationProvider(nil)

        let endpoint = ParraEndpoint.postAuthentication(
            tenantId: mockNetworkManager.tenantId
        )
        let expectation = mockNetworkManager.urlSession.expectInvocation(
            of: endpoint
        )
        expectation.isInverted = true

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
            tenantId: mockNetworkManager.tenantId
        )
        let authEndpointExpectation = mockNetworkManager.urlSession.expectInvocation(
            of: endpoint
        )

        let authProviderExpectation = XCTestExpectation()
        await mockNetworkManager.networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()

            return token
        }

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
            endpoint: endpoint
        )

        await fulfillment(
            of: [authProviderExpectation, authEndpointExpectation],
            timeout: 0.2
        )

        let persistedCredential = await mockNetworkManager.dataManager.getCurrentCredential()
        XCTAssertEqual(token, persistedCredential?.token)
    }

    func testThrowingAuthenticationHandlerFailsRequest() async throws {
        await mockNetworkManager.networkManager.updateAuthenticationProvider { () async throws -> String in
            throw URLError(.cannotLoadFromNetwork)
        }

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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

        await mockNetworkManager.dataManager.updateCredential(credential: credential)

        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.isInverted = true
        await mockNetworkManager.networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()

            return token
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
        let endpoint = ParraEndpoint.postBulkSubmitSessions(tenantId: mockNetworkManager.tenantId)
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint) { request in

            return (request.allHTTPHeaderFields ?? [:]).keys.contains { headerKey in
                return headerKey == "X-PARRA-PLATFORM-SDK-VERSION"
            }
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint) { request in

            return request.httpBody == nil
        }

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
            endpoint: endpoint
        )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testSendsBodyWithNonGetRequests() async throws {
        let endpoint = ParraEndpoint.postBulkSubmitSessions(
            tenantId: mockNetworkManager.tenantId
        )

        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint) { request in

            let encoded = try JSONEncoder.parraEncoder.encode(EmptyRequestObject())

            return request.httpBody == encoded
        }

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
            endpoint: endpoint
        )

        await fulfillment(of: [endpointExpectation], timeout: 0.1)
    }

    func testHandlesNoContentHeader() async throws {
        let endpoint = ParraEndpoint.getCards
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint, toReturn:  {
            return (204, "{\"key\":\"not empty\"}".data(using: .utf8)!)
        })

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint, toReturn:  {
            return (400, .emptyJsonObject)
        })

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(of: endpoint, toReturn:  {
            return (500, .emptyJsonObject)
        })

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(
            of: endpoint,
            times: 2,
            toReturn: {
            if isFirstRequest {
                isFirstRequest = false
                return (401, .emptyJsonObject)
            }

            return (200, .emptyJsonObject)
        })

        let authProviderExpectation = XCTestExpectation()
        await mockNetworkManager.networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()

            return UUID().uuidString
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
            endpoint: endpoint
        )

        await fulfillment(of: [endpointExpectation, authProviderExpectation], timeout: 0.1)

        switch response.result {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }

    func testReauthenticationFailure() async throws {
        await mockNetworkManager.networkManager.updateAuthenticationProvider { () async throws -> String in
            throw URLError(.networkConnectionLost)
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await mockNetworkManager.networkManager.performAuthenticatedRequest(
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
            tenantId: mockNetworkManager.tenantId
        )
        let endpointExpectation = mockNetworkManager.urlSession.expectInvocation(
            of: endpoint,
            toReturn: {
                let data = try JSONEncoder.parraEncoder.encode(
                    ParraCredential(token: UUID().uuidString)
                )

                return (200, data)
            })

        let _ = try await mockNetworkManager.networkManager.performPublicApiKeyAuthenticationRequest(
            forTentant: mockNetworkManager.tenantId,
            applicationId: mockNetworkManager.applicationId,
            apiKeyId: UUID().uuidString,
            userId: UUID().uuidString
        )

        await fulfillment(
            of: [endpointExpectation],
            timeout: 0.1
        )
    }
}

