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


//fileprivate let testBase64TokenString = "gHdLonk9TsQIRKG8Jhagnb1+ehF+g/qXyfPjb2O23qH4PlDAdS+m8crD0UXgH/oQm2ycdmv3Rnjt7HEYrdBM4E0g+a8HDrKFitM2RHBYPVg="
//fileprivate let testTokenData = Data(base64Encoded: testBase64TokenString)!
//fileprivate let testTokenString = testTokenData.map { String(format: "%02.2hhx", $0) }.joined()
//
//fileprivate let testConfig = {
//    var config = ParraConfiguration(loggerConfig: .default)
//    config.applicationId = UUID().uuidString
//    config.tenantId = UUID().uuidString
//
//    return config
//}()
//
//@MainActor
//class ParraPushTests: XCTestCase {
//    override class func setUp() {
//        super.setUp()
//    }
//
//    override func setUp() async throws {
//        await ParraGlobalState.shared.deinitialize()
//        await ParraGlobalState.shared.clearTemporaryPushToken()
//        await ParraConfigState.shared.updateState(.default)
//    }
//
//    func testRegisterDataTriggersUpdate() async {
//        await ParraGlobalState.shared.initialize()
//        await ParraConfigState.shared.updateState(testConfig)
//
//        let pushUploadExpectation = XCTestExpectation()
//
//        await configureWithRequestResolverOnly { request in
//            pushUploadExpectation.fulfill()
//
//            return (EmptyJsonObjectData, createTestResponse(route: "whatever", statusCode: 200), nil)
//        }
//
//        Parra.registerDevicePushToken(testTokenData)
//
//        await fulfillment(of: [pushUploadExpectation], timeout: 2)
//    }
//
//    func testCachesPushTokenIfSdkNotInitialized() async throws {
//        await ParraGlobalState.shared.deinitialize()
//        await Parra.registerDevicePushTokenString(testTokenString)
//        let cachedToken = await ParraGlobalState.shared.getCachedTemporaryPushToken()
//        XCTAssertEqual(cachedToken, testTokenString)
//    }
//
//    func testRegistrationAfterInitializationUploadsToken() async {
//        await ParraGlobalState.shared.initialize()
//        await ParraConfigState.shared.updateState(testConfig)
//        await configureWithRequestResolverOnly { request in
//            return (EmptyJsonObjectData, createTestResponse(route: "whatever", statusCode: 204), nil)
//        }
//
//        await Parra.registerDevicePushTokenString(testTokenString)
//
//        let cached = await ParraGlobalState.shared.getCachedTemporaryPushToken()
//        XCTAssertNil(cached)
//    }
//
//    func testRegistrationUploadFailureStoresToken() async {
//        await ParraGlobalState.shared.initialize()
//        await Parra.registerDevicePushTokenString(testTokenString)
//
//        await configureWithRequestResolverOnly { request in
//            return (EmptyJsonObjectData, createTestResponse(route: "whatever", statusCode: 400), nil)
//        }
//
//        await Parra.registerDevicePushTokenString(testTokenString)
//
//        let cached = await ParraGlobalState.shared.getCachedTemporaryPushToken()
//        XCTAssertNotNil(cached)
//    }
//
//    func testRegistrationFailureProducesArtifact() async {
//        await ParraGlobalState.shared.initialize()
//        await ParraConfigState.shared.updateState(testConfig)
//
//        let pushUploadExpectation = XCTestExpectation()
//
//        await configureWithRequestResolverOnly { request in
//            pushUploadExpectation.fulfill()
//
//            return (EmptyJsonObjectData, createTestResponse(route: "whatever", statusCode: 204), nil)
//        }
//
//        await Parra.registerDevicePushTokenString(testTokenString)
//
//        await fulfillment(of: [pushUploadExpectation], timeout: 0.1)
//    }
//
//    func testInitializationAfterRegistrationClearsToken() async {
//        await configureWithRequestResolverOnly { request in
//            return (EmptyJsonObjectData, createTestResponse(route: "whatever", statusCode: 200), nil)
//        }
//
//        await ParraGlobalState.shared.setTemporaryPushToken(testTokenString)
//
//        await Parra.initialize(authProvider: .default(tenantId: "tenant", applicationId: "myapp", authProvider: {
//            return UUID().uuidString
//        }))
//
//        let cached = await ParraGlobalState.shared.getCachedTemporaryPushToken()
//        XCTAssertNil(cached)
//    }
//
//    func testAcceptsRegistrationFailure() async {
//        let error = ParraError.custom("made up error", nil)
//        Parra.didFailToRegisterForRemoteNotifications(with: error)
//    }
//}
//
