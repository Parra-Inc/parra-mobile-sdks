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
    
    func testSetAuthenticationProviderAsyncFunc() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider({
            return token
        })
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testSetAuthenticationProviderCompletionHandlerFunc() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (String) -> Void) in
            completion(token)
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    
    func testSetAuthenticationProviderCompletionHandlerNonThrowingFunc() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (String) -> Void) in
            completion(token)
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testSetAuthenticationProviderResultFunc() async throws {
        let token = UUID().uuidString
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (Result<String, Error>) -> Void) in
            completion(.success(token))
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testAsyncConversionFromCompletionHandlerSuccess() async throws {
        let token = UUID().uuidString

        Parra.setAuthenticationProvider { (completion: (String) -> Void) in
            completion(token)
        }
        
        let result = try await Parra.shared.networkManager.authenticationProvider!()
        
        XCTAssertEqual(result, token)
    }
    
    func testAsyncConversionFromCompletionHandlerFailure() async throws {
        Parra.setAuthenticationProvider { (completion: (String) -> Void) in
            throw URLError(.badServerResponse)
        }
        
        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()
            
            XCTFail()
        } catch {}
    }
    
    func testAsyncConversionFromResultSuccess() async throws {
        let token = UUID().uuidString

        Parra.setAuthenticationProvider { (completion: (Result<String, Error>) -> Void) in
            completion(.success(token))
        }

        let result = try await Parra.shared.networkManager.authenticationProvider!()
        
        XCTAssertEqual(result, token)
    }

    func testAsyncConversionFromResultFailure() async throws {
        Parra.setAuthenticationProvider { (completion: (Result<String, Error>) -> Void) in
            completion(.failure(URLError(.badServerResponse)))
        }

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
        
        let syncManager = ParraSyncManager(
            networkManager: networkManager
        )
        
        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
    }

    func testSetPublicApiKeyAuthenticationProvider() async throws {
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setPublicApiKeyAuthProvider(
            tenantId: UUID().uuidString,
            apiKeyId: UUID().uuidString
        ) {
            return UUID().uuidString
        }

        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }

    func testAsyncConversionFromPublicApiKeyAuthProvider() async throws {
        let dataManager = ParraDataManager()
        let tenantId = UUID().uuidString
        let route = "tenants/\(tenantId)/issuers/public/auth/token"
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: MockURLSession { request in
                let data = try! JSONEncoder().encode(ParraCredential(token: UUID().uuidString))
                return (data, createTestResponse(route: route), nil)
            }
        )

        let syncManager = ParraSyncManager(
            networkManager: networkManager
        )

        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )

        let authProviderExpectation = XCTestExpectation()

        Parra.setPublicApiKeyAuthProvider(
            tenantId: UUID().uuidString,
            apiKeyId: UUID().uuidString
        ) {
            authProviderExpectation.fulfill()
            return UUID().uuidString
        }

        let _ = try await Parra.shared.networkManager.authenticationProvider!()

        wait(for: [authProviderExpectation], timeout: 0.1)
    }
}
