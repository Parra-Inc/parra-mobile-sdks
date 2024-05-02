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
        return compactMap {
            let key = $0.key as NSString
            let value = $0.value as NSString

            guard
                let encodedKey = key.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ),
                let encodedValue = value.addingPercentEncoding(
                    withAllowedCharacters: .urlQueryAllowed
                ) else
            {
                return nil
            }

            return URLQueryItem(
                name: encodedKey,
                value: encodedValue
            )
        }
    }
}
