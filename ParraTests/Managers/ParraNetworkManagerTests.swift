//
//  ParraNetworkManagerTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import Parra

let fakeModule = FakeModule()

@MainActor
class ParraNetworkManagerTests: XCTestCase {
    override func setUp() async throws {
        await ParraGlobalState.shared.registerModule(module: fakeModule)

        await Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
            return UUID().uuidString
        }))
    }

    override func tearDown() async throws {
        await Parra.deinitialize()
        await ParraGlobalState.shared.unregisterModule(module: fakeModule)
    }

    func testAuthenticatedRequestFailsWithoutAuthProvider() async throws {
        let networkManager = ParraNetworkManager(
            dataManager: MockDataManager(),
            urlSession: MockURLSession { request in
                return (nil, nil, nil)
            }
        )

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: "whatever", method: .get)
        )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
    
    func testAuthenticatedRequestInvokesAuthProvider() async throws {
        let dataManager = MockDataManager()
        let token = UUID().uuidString
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (EmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        await networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()
            
            return token
        }

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        await fulfillment(of: [authProviderExpectation], timeout: 0.1)

        let persistedCredential = await dataManager.getCurrentCredential()
        XCTAssertEqual(token, persistedCredential?.token)
    }
    
    func testThrowingAuthenticationHandlerFailsRequest() async throws {
        let dataManager = MockDataManager()
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (EmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        await networkManager.updateAuthenticationProvider { () async throws -> String in
            throw URLError(.cannotLoadFromNetwork)
        }
        
        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
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
        let dataManager = MockDataManager()
        
        await dataManager.updateCredential(credential: credential)
        
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (EmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.isInverted = true
        await networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()
            
            return token
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success:
            await fulfillment(of: [authProviderExpectation], timeout: 0.1)
        case .failure(let error):
            throw error
        }
    }
    
    func testSendsLibraryVersionHeaderForRegisteredModules() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)

        await dataManager.updateCredential(credential: credential)

        let notificationCenter = ParraNotificationCenter.default

        let endpoint = ParraEndpoint.postBulkSubmitSessions(tenantId: "whatever")
        let requestHeadersExpectation = XCTestExpectation()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let matches = (request.allHTTPHeaderFields ?? [:]).keys.contains { headerKey in
                    return headerKey == "X-PARRA-PLATFORM-SDK-VERSION"
                }
                
                if matches {
                    requestHeadersExpectation.fulfill()
                }
                
                return (EmptyJsonObjectData, createTestResponse(route: endpoint.route), nil)
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

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: endpoint
        )

        switch response.result {
        case .success:
            await fulfillment(of: [requestHeadersExpectation], timeout: 0.1)
        case .failure(let error):
            throw error
        }
    }
    
    func testSendsNoBodyWithGetRequests() async throws {
        let dataManager = MockDataManager()
        let route = "whatever"
        let jsonEncoder = JSONEncoder.parraEncoder

        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let requestBodyExpectation = XCTestExpectation()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                if request.httpBody == nil {
                    requestBodyExpectation.fulfill()
                }

                return (EmptyJsonObjectData, createTestResponse(route: route), nil)
            },
            jsonEncoder: jsonEncoder
        )

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        await fulfillment(of: [requestBodyExpectation], timeout: 0.1)
    }

    func testSendsBodyWithNonGetRequests() async throws {
        let dataManager = MockDataManager()
        let route = "whatever"
        let bodyObject = EmptyRequestObject()
        let jsonEncoder = JSONEncoder.parraEncoder

        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let requestBodyExpectation = XCTestExpectation()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let encoded = try! jsonEncoder.encode(bodyObject)
                if request.httpBody == encoded {
                    requestBodyExpectation.fulfill()
                }

                return (EmptyJsonObjectData, createTestResponse(route: route), nil)
            },
            jsonEncoder: jsonEncoder
        )

        let _: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .post)
        )

        await fulfillment(of: [requestBodyExpectation], timeout: 0.1)
    }

    func testHandlesNoContentHeader() async throws {
        let credential = ParraCredential(token: UUID().uuidString)
        let dataManager = MockDataManager()
        let jsonEncoder = JSONEncoder.parraEncoder
        jsonEncoder.outputFormatting = []
        
        await dataManager.updateCredential(credential: credential)
        
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return ("{\"key\":\"not empty\"}".data(using: .utf8)!, createTestResponse(route: route, statusCode: 204), nil)
            },
            jsonEncoder: jsonEncoder
        )

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success(let data):
            XCTAssertEqual(EmptyJsonObjectData, try! jsonEncoder.encode(data))
        case .failure(let error):
            throw error
        }
    }
    
    func testClientErrorsFailRequests() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 400), nil)
            }
        )

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
    
    func testServerErrorsFailRequests() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 500), nil)
            }
        )

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }
    
    func testReauthenticationSuccess() async throws {
        var isFirstRequest = true
        
        let dataManager = MockDataManager()
        let token = UUID().uuidString
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                if isFirstRequest {
                    isFirstRequest = false

                    return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 401), nil)
                }

                return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 200), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        await networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()
            
            return token
        }

        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success:
            break
        case .failure(let error):
            throw error
        }
    }
    
    func testReauthenticationFailure() async throws {
        var isFirstRequest = true
        
        let dataManager = MockDataManager()
        let token = UUID().uuidString
        let credential = ParraCredential(token: token)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                if isFirstRequest {
                    isFirstRequest = false

                    return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 401), nil)
                }

                return (EmptyJsonObjectData, createTestResponse(route: route, statusCode: 400), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        await networkManager.updateAuthenticationProvider { () async throws -> String in
            authProviderExpectation.fulfill()
            
            return token
        }

        // Can't expect throw with async func
        let response: AuthenticatedRequestResult<EmptyResponseObject> = await networkManager.performAuthenticatedRequest(
            endpoint: .custom(route: route, method: .get)
        )

        switch response.result {
        case .success:
            XCTFail()
        case .failure:
            break
        }
    }

    func testPublicApiKeyAuthentication() async throws {
        let tenantId = UUID().uuidString
        let applicationId = UUID().uuidString
        let apiKeyId = UUID().uuidString
        let userId = UUID().uuidString

        let dataManager = MockDataManager()
        let notificationCenter = ParraNotificationCenter.default

        let route = "whatever"
        let requestExpectation = XCTestExpectation()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let data = try! JSONEncoder().encode(ParraCredential(token: UUID().uuidString))
                requestExpectation.fulfill()
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

        let _ = try await networkManager.performPublicApiKeyAuthenticationRequest(
            forTentant: tenantId,
            applicationId: applicationId,
            apiKeyId: apiKeyId,
            userId: userId
        )

        await fulfillment(of: [requestExpectation], timeout: 0.1)
    }
}

