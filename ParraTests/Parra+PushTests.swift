//
//  Parra+PushTests.swift
//  ParraTests
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import XCTest
import Foundation
@testable import Parra


fileprivate let testBase64TokenString = "gHdLonk9TsQIRKG8Jhagnb1+ehF+g/qXyfPjb2O23qH4PlDAdS+m8crD0UXgH/oQm2ycdmv3Rnjt7HEYrdBM4E0g+a8HDrKFitM2RHBYPVg="
fileprivate let testToken = Data(base64Encoded: testBase64TokenString)!
fileprivate let testTokenString = testToken.map { String(format: "%02.2hhx", $0) }.joined()

class ParraPushTests: MockedParraTestCase {
    override func setUp() async throws {
        try createBaseDirectory()

        // Setup without initialization
        mockParra = await createMockParra(state: .uninitialized)
    }

    override func tearDown() async throws {
        if let mockParra {
            try await mockParra.tearDown()
            await mockParra.parra.state.deinitialize()
        }

        try await super.tearDown()
    }

    func testRegisterDataTriggersUpdate() async {
        await mockParra.parra.initialize(authProvider: .mockPublicKey(mockParra))

        let pushUploadExpectation = mockParra.mockNetworkManager.urlSession.expectInvocation(
            of: .postPushTokens(tenantId: mockParra.tenantId)
        )

        await mockParra.parra.registerDevicePushToken(testToken)

        await fulfillment(of: [pushUploadExpectation])
    }

    func testCachesPushTokenIfSdkNotInitialized() async throws {
        await mockParra.parra.registerDevicePushToken(testToken)

        let cachedToken = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertEqual(cachedToken, testTokenString)
    }

    func testRegistrationAfterInitializationUploadsToken() async {
        await mockParra.parra.initialize(authProvider: .mockPublicKey(mockParra))
        await mockParra.parra.registerDevicePushToken(testToken)

        let cachedToken = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertNil(cachedToken)
    }

    func testRegistrationUploadFailureStoresToken() async {
        await mockParra.parra.state.clearTemporaryPushToken()
        let cachedTokenBefore = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertNil(cachedTokenBefore)

        let pushUploadExpectation = mockParra.mockNetworkManager.urlSession.expectInvocation(
            of: .postPushTokens(tenantId: mockParra.tenantId),
            toReturn: {
                throw URLError(.networkConnectionLost)
            }
        )

        await mockParra.parra.initialize(authProvider: .mockPublicKey(mockParra))
        await mockParra.parra.registerDevicePushToken(testToken)

        await fulfillment(of: [pushUploadExpectation], timeout: 2)

        let cachedTokenAfter = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertNotNil(cachedTokenAfter)
    }

    func testInitializationAfterRegistrationClearsToken() async {
        await mockParra.parra.registerDevicePushToken(testToken)

        let cachedToken = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertNotNil(cachedToken)

        await mockParra.parra.initialize(authProvider: .mockPublicKey(mockParra))

        let cachedTokenAfter = await mockParra.parra.state.getCachedTemporaryPushToken()
        XCTAssertNil(cachedTokenAfter)
    }

    func testAcceptsRegistrationFailure() async throws {
        let error = ParraError.generic("made up error", nil)
        // no op for now
        await mockParra.parra.didFailToRegisterForRemoteNotifications(with: error)

        XCTAssertTrue(true)
    }
}

