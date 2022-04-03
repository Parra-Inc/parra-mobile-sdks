//
//  ParraNetworkManagerTests.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 3/20/22.
//

import XCTest
@testable import ParraCore

class ParraNetworkManagerTests: XCTestCase {
    func testAuthenticatedRequestFailsWithoutAuthProvider() async throws {
        let networkManager = ParraNetworkManager(
            dataManager: MockDataManager(),
            urlSession: MockURLSession { request in
                return (nil, nil, nil)
            }
        )

        // Can't expect throw with async func
        do {
            let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(route: "whatever", method: .get)
            
            XCTFail()
        } catch {}
    }
    
    func testAuthenticatedRequestInvokesAuthProvider() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (kEmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        networkManager.updateAuthenticationProvider { () async throws -> ParraCredential in
            authProviderExpectation.fulfill()
            
            return credential
        }

        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .get
        )
        
        wait(for: [authProviderExpectation], timeout: 0.1)
        let persistedCredential = await dataManager.getCurrentCredential()
        XCTAssertEqual(credential, persistedCredential)
    }
    
    func testThrowingAuthenticationHandlerFailsRequest() async throws {
        let dataManager = MockDataManager()
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (kEmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        networkManager.updateAuthenticationProvider { () async throws -> ParraCredential in
            throw URLError(.cannotLoadFromNetwork)
        }
        
        // Can't expect throw with async func
        do {
            let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
                route: route,
                method: .get
            )

            XCTFail()
        } catch {}
    }
    
    func testDoesNotRefreshCredentialWhenOneIsPresent() async throws {
        let credential = ParraCredential(token: UUID().uuidString)
        let dataManager = MockDataManager()
        
        await dataManager.updateCredential(credential: credential)
        
        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (kEmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        authProviderExpectation.isInverted = true
        networkManager.updateAuthenticationProvider { () async throws -> ParraCredential in
            authProviderExpectation.fulfill()
            
            return credential
        }
        
        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .get
        )

        wait(for: [authProviderExpectation], timeout: 0.1)
    }
    
    func testSendsLibraryVersionHeadersForRegisteredModules() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)

        await dataManager.updateCredential(credential: credential)
        
        let route = "whatever"
        let requestHeadersExpectation = XCTestExpectation()
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let matches = request.allHTTPHeaderFields!.keys.contains { headerKey in
                    return headerKey.lowercased().contains(FakeModule.name.lowercased())
                }
                
                if matches {
                    requestHeadersExpectation.fulfill()
                }
                
                return (kEmptyJsonObjectData, createTestResponse(route: route), nil)
            }
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: ParraFeedbackSyncManager(networkManager: networkManager),
            networkManager: networkManager
        )
        
        Parra.registerModule(module: FakeModule())
        
        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .get
        )
        
        wait(for: [requestHeadersExpectation], timeout: 0.1)
    }
    
    func testSendsBodyWithRequests() async throws {
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
                
                return (kEmptyJsonObjectData, createTestResponse(route: route), nil)
            },
            jsonEncoder: jsonEncoder
        )
                
        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .post,
            body: bodyObject
        )

        wait(for: [requestBodyExpectation], timeout: 0.1)
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
                
        let response: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .get
        )

        XCTAssertEqual(kEmptyJsonObjectData, try! jsonEncoder.encode(response))
    }
    
    func testClientErrorsFailRequests() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 400), nil)
            }
        )

        // Can't expect throw with async func
        do {
            let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
                route: route,
                method: .get
            )

            XCTFail()
        } catch {}
    }
    
    func testServerErrorsFailRequests() async throws {
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 500), nil)
            }
        )

        // Can't expect throw with async func
        do {
            let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
                route: route,
                method: .get
            )

            XCTFail()
        } catch {}
    }
    
    func testReauthenticationSuccess() async throws {
        var isFirstRequest = true
        
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                if isFirstRequest {
                    isFirstRequest = false

                    return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 401), nil)
                }

                return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 200), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        networkManager.updateAuthenticationProvider { () async throws -> ParraCredential in
            authProviderExpectation.fulfill()
            
            return credential
        }

        let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
            route: route,
            method: .get
        )
    }
    
    func testReauthenticationFailure() async throws {
        var isFirstRequest = true
        
        let dataManager = MockDataManager()
        let credential = ParraCredential(token: UUID().uuidString)
        await dataManager.updateCredential(credential: credential)

        let route = "whatever"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                if isFirstRequest {
                    isFirstRequest = false

                    return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 401), nil)
                }

                return (kEmptyJsonObjectData, createTestResponse(route: route, statusCode: 400), nil)
            }
        )
        
        let authProviderExpectation = XCTestExpectation()
        networkManager.updateAuthenticationProvider { () async throws -> ParraCredential in
            authProviderExpectation.fulfill()
            
            return credential
        }

        // Can't expect throw with async func
        do {
            let _: EmptyResponseObject = try await networkManager.performAuthenticatedRequest(
                route: route,
                method: .get
            )

            XCTFail()
        } catch {}

    }
}

