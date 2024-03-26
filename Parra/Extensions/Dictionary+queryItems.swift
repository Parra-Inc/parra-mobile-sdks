//
//  Dictionary+queryItems.swift
//  Parra
//
//  Created by Mick MacCallum on 3/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension [String: String] {
    var queryItems: [URLQueryItem] {
        map { URLQueryItem(name: $0.key, value: $0.value) }
    }
}
