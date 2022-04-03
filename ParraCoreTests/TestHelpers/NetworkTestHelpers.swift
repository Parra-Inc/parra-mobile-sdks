//
//  NetworkTestHelpers.swift
//  ParraCoreTests
//
//  Created by Mick MacCallum on 4/3/22.
//

import Foundation
@testable import ParraCore

func createTestResponse(route: String,
                        statusCode: Int = 200,
                        additionalHeaders: [String: String] = [:]) -> HTTPURLResponse {

    let url = Parra.Constant.parraApiRoot.appendingPathComponent(route)

    return HTTPURLResponse(
        url: url,
        statusCode: statusCode,
        httpVersion: "HTTP/1.1",
        headerFields: [:].merging(additionalHeaders) { (_, new) in new }
    )!
}
