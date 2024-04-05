//
//  URLSessionType.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol URLSessionType {
    func dataForRequest(
        for request: URLRequest,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)

    var configuration: URLSessionConfiguration { get }
}
