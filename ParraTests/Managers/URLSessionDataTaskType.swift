//
//  URLSessionDataTaskType.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal protocol URLSessionDataTaskType {
    func resume()
}

internal extension URLSessionDataTask: URLSessionDataTaskType {}
