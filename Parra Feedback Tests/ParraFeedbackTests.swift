//
//  ParraFeedbackTests.swift
//  Parra Feedback Tests
//
//  Created by Michael MacCallum on 1/15/22.
//

import XCTest
@testable import ParraFeedback

class ParraFeedbackTests: XCTestCase {    
    func testInitialize() throws {
        let credential = ParraFeedbackUserCredential.defaultCredential
        let authProviderExpectation = expectation(description: "Expect initializer callback")
        let authCompleteExpectation = expectation(description: "Expect completed authentication")

        ParraFeedback.initialize(authenticationProvider: {
            authProviderExpectation.fulfill()
            return credential
        }) { result in
            switch result {
            case .success(_):
                authCompleteExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
        
        XCTAssertTrue(UIFont.fontsRegistered)
        XCTAssert(ParraFeedback.shared.cachedUserCredential == credential)
    }
    
    func testInitializeFailure() throws {
        let authFailureExpectation = expectation(description: "Expect completed authentication")
        let error = NSError(domain: "test", code: 100)
        
        ParraFeedback.initialize(authenticationProvider: {
            throw error
        }) { result in
            switch result {
            case .success(let credential):
                XCTFail("auth unexpectedly succeeded with credential: \(credential)")
            case .failure(_):
                authFailureExpectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
        
        XCTAssertTrue(UIFont.fontsRegistered)
        XCTAssert(ParraFeedback.shared.cachedUserCredential == nil)
    }

    func testSetUserCredential() {
        let credential = ParraFeedbackUserCredential(
            token: UUID().uuidString,
            name: "Test"
        )
        
        ParraFeedback.setUserCredential(credential)
        
        XCTAssert(ParraFeedback.shared.cachedUserCredential == credential)
    }

    func testLogout() throws {
        ParraFeedback.logout()
        
        XCTAssert(ParraFeedback.shared.cachedUserCredential == nil)
    }

    func testFetchFeedbackCardsWithNoAuth() async throws {
        ParraFeedback.logout()
        
        // XCTAssertThrowsError doesn't support async yet.
        do {
            let _ = try await ParraFeedback.fetchFeedbackCards()
            
            XCTFail("fetching cards without credentials should fail")
        } catch let error as ParraFeedbackError {
            XCTAssert(error == .missingAuthentication)
        } catch let error {
            XCTFail("fetching cards failed with unexpected error: \(error)")
        }
    }
    
    func testFetchFeedbackCardsWithAuth() async throws {
        let credential = ParraFeedbackUserCredential(
            token: UUID().uuidString,
            name: "Test"
        )
        
        ParraFeedback.setUserCredential(credential)

        let response = try await ParraFeedback.fetchFeedbackCards()

        XCTAssert(!response.items.isEmpty)
    }
}
