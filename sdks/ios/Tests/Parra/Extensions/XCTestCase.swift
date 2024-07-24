//
//  XCTestCase.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra
import XCTest

extension XCTestCase {
    func addJsonAttachment(
        value: some Encodable,
        name: String? = nil,
        lifetime: XCTAttachment.Lifetime = .deleteOnSuccess,
        userInfo: [AnyHashable: Any] = [:]
    ) throws {
        let data = try JSONEncoder.parraEncoder.encode(value)

        addJsonAttachment(
            data: data,
            name: name,
            lifetime: lifetime,
            userInfo: userInfo
        )
    }

    func addJsonAttachment(
        data: Data,
        name: String? = nil,
        lifetime: XCTAttachment.Lifetime = .deleteOnSuccess,
        userInfo: [AnyHashable: Any] = [:]
    ) {
        let jsonAttachment = XCTAttachment(
            data: data,
            uniformTypeIdentifier: "public.json"
        )
        jsonAttachment.name = name
        jsonAttachment.lifetime = lifetime
        jsonAttachment.userInfo = userInfo

        add(jsonAttachment)
    }
}
