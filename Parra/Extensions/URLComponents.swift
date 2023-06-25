//
//  URLComponents.swift
//  Parra
//
//  Created by Mick MacCallum on 9/18/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

extension URLComponents {
    mutating func setQueryItems(with parameters: [String: String]) {
        queryItems = parameters.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
    }
}
