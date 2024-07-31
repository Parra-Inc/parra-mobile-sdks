//
//  Dictionary+queryItems.swift
//  Parra
//
//  Created by Mick MacCallum on 3/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension [String: String] {
    /// I want this name to be abundantly clear that query items returned by
    /// this will be properly escaped, since we've had issues with Apple's
    /// default charsets including unallowed characters unescaped.
    var asCorrectlyEscapedQueryItems: [URLQueryItem] {
        return compactMap {
            let key = $0.key as NSString
            let value = $0.value as NSString

            guard
                let encodedKey = key.addingPercentEncoding(
                    withAllowedCharacters: .rfc3986Unreserved
                ),
                let encodedValue = value.addingPercentEncoding(
                    withAllowedCharacters: .rfc3986Unreserved
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
