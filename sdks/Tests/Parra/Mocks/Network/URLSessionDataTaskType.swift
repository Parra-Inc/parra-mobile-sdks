//
//  URLSessionDataTaskType.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol URLSessionDataTaskType {
    func resume()
}

// MARK: - URLSessionDataTask + URLSessionDataTaskType

extension URLSessionDataTask: URLSessionDataTaskType {}
