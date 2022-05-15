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
        let credential = ParraCredential(token: UUID().uuidString)
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider({
            return credential
        })
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testSetAuthenticationProviderCompletionHandlerFunc() async throws {
        let credential = ParraCredential(token: UUID().uuidString)
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (ParraCredential) -> Void) in
            completion(credential)
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    
    func testSetAuthenticationProviderCompletionHandlerNonThrowingFunc() async throws {
        let credential = ParraCredential(token: UUID().uuidString)
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (ParraCredential) -> Void) in
            completion(credential)
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testSetAuthenticationProviderResultFunc() async throws {
        let credential = ParraCredential(token: UUID().uuidString)
        XCTAssertNil(Parra.shared.networkManager.authenticationProvider)

        Parra.setAuthenticationProvider { (completion: (Result<ParraCredential, Error>) -> Void) in
            completion(.success(credential))
        }
        
        XCTAssertNotNil(Parra.shared.networkManager.authenticationProvider)
    }
    
    func testAsyncConversionFromCompletionHandlerSuccess() async throws {
        let credential = ParraCredential(token: UUID().uuidString)

        Parra.setAuthenticationProvider { (completion: (ParraCredential) -> Void) in
            completion(credential)
        }
        
        let result = try await Parra.shared.networkManager.authenticationProvider!()
        
        XCTAssertEqual(result, credential)
    }
    
    func testAsyncConversionFromCompletionHandlerFailure() async throws {
        Parra.setAuthenticationProvider { (completion: (ParraCredential) -> Void) in
            throw URLError(.badServerResponse)
        }
        
        do {
            let _ = try await Parra.shared.networkManager.authenticationProvider!()
            
            XCTFail()
        } catch {}
    }
    
    func testAsyncConversionFromResultSuccess() async throws {
        let credential = ParraCredential(token: UUID().uuidString)

        Parra.setAuthenticationProvider { (completion: (Result<ParraCredential, Error>) -> Void) in
            completion(.success(credential))
        }

        let result = try await Parra.shared.networkManager.authenticationProvider!()
        
        XCTAssertEqual(result, credential)
    }

    func testAsyncConversionFromResultFailure() async throws {
        Parra.setAuthenticationProvider { (completion: (Result<ParraCredential, Error>) -> Void) in
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
        
        let syncManager = ParraFeedbackSyncManager(
            networkManager: networkManager
        )
        
        Parra.shared = Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
    }
}
