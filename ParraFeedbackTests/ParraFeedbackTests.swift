//
//  ParraFeedbackTests.swift
//  ParraFeedbackTests
//
//  Created by Mick MacCallum on 3/13/22.
//

import XCTest
@testable import ParraFeedback

//private let credential = ParraCredential(token: UUID().uuidString)

class ParraFeedbackTests: XCTestCase {

    override func setUp() async throws {
        try await super.setUp()
        
//        ParraFeedback.shared = ParraFeedback(
//            dataManager: ParraFeedbackDataManager()
//        )
    }
    
    func testFontsRegistered() {
//        XCTAssertTrue(UIFont.fontsRegistered)
    }
    
    func testSetAuthenticationProvider() async throws {
        
//        let authProviderExpectation = expectation(description: "Expect initializer callback")

//        XCTAssertNil(ParraFeedback.shared.authenticationProvider)
//        ParraFeedback.setAuthenticationProvider { (completion: @escaping (ParraCredential) -> Void) in
////            authProviderExpectation.fulfill()
//            completion(credential)
//        }
        
//        XCTAssertNotNil(ParraFeedback.shared.authenticationProvider)
        
//        await waitForExpectations(timeout: 2.0, handler: nil)
        
//        XCTAssert(ParraFeedback.shared.cachedUserCredential == credential)
    }
    
//    func testEnsureInitialized() async throws {
//        XCTAssertFalse(ParraFeedback.shared.isInitialized)
//        await ParraFeedback.shared.ensureInitialized()
//        XCTAssertTrue(ParraFeedback.shared.isInitialized)
//        XCTAssertTrue(ParraFeedback.shared.dataManager.isLoaded)
//    }
    
//    func testInitializeFailure() throws {
//        let authFailureExpectation = expectation(description: "Expect completed authentication")
//        let error = NSError(domain: "test", code: 100)
//
//        ParraFeedback.initialize(authenticationProvider: {
//            throw error
//        }) { result in
//            switch result {
//            case .success(let credential):
//                XCTFail("auth unexpectedly succeeded with credential: \(credential)")
//            case .failure(_):
//                authFailureExpectation.fulfill()
//            }
//        }
//
//        waitForExpectations(timeout: 2.0, handler: nil)
//
//        XCTAssertTrue(UIFont.fontsRegistered)
//        XCTAssert(ParraFeedback.shared.cachedUserCredential == nil)
//    }
//
//    func testSetUserCredential() {
//        let credential = ParraFeedbackUserCredential(
//            token: UUID().uuidString,
//            name: "Test"
//        )
//
//        ParraFeedback.setUserCredential(credential)
//
//        XCTAssert(ParraFeedback.shared.cachedUserCredential == credential)
//    }
//
//    func testLogout() throws {
//        ParraFeedback.logout()
//
//        XCTAssert(ParraFeedback.shared.cachedUserCredential == nil)
//    }
//
//    func testFetchFeedbackCardsWithNoAuth() async throws {
//        ParraFeedback.logout()
//
//        // XCTAssertThrowsError doesn't support async yet.
//        do {
//            let _ = try await ParraFeedback.fetchFeedbackCards()
//
//            XCTFail("fetching cards without credentials should fail")
//        } catch let error as ParraError {
//            XCTAssert(error == .missingAuthentication)
//        } catch let error {
//            XCTFail("fetching cards failed with unexpected error: \(error)")
//        }
//    }
//
//    func testFetchFeedbackCardsWithAuth() async throws {
//        let credential = ParraFeedbackUserCredential(
//            token: UUID().uuidString,
//            name: "Test"
//        )
//
//        ParraFeedback.setUserCredential(credential)
//
//        let response = try await ParraFeedback.fetchFeedbackCards()
//
//        XCTAssert(!response.items.isEmpty)
//    }
}
