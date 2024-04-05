//
//  Parra+PushTests.swift
//  Tests
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra
import XCTest

private let testBase64TokenString =
    "gHdLonk9TsQIRKG8Jhagnb1+ehF+g/qXyfPjb2O23qH4PlDAdS+m8crD0UXgH/oQm2ycdmv3Rnjt7HEYrdBM4E0g+a8HDrKFitM2RHBYPVg="
private let testToken = Data(base64Encoded: testBase64TokenString)!
private let testTokenString = testToken.map { String(format: "%02.2hhx", $0) }
    .joined()

class ParraPushTests: MockedParraTestCase {
    func testRegisterDataTriggersUpdate() async {
        await mockParra.parra.parraInternal
            .initialize(with: .mockPublicKey(mockParra))

        let pushUploadExpectation = mockParra.mockNetworkManager.urlSession
            .expectInvocation(
                of: .postPushTokens(tenantId: mockParra.appState.tenantId)
            )

        await mockParra.parra.registerDevicePushToken(testToken)

        await fulfillment(of: [pushUploadExpectation])
    }

    func testAcceptsRegistrationFailure() async throws {
        let error = ParraError.generic("made up error", nil)
        // no op for now
        await mockParra.parra
            .didFailToRegisterForRemoteNotifications(with: error)

        XCTAssertTrue(true)
    }
}
