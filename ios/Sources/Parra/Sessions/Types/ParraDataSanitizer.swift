//
//  ParraDataSanitizer.swift
//  Parra
//
//  Created by Mick MacCallum on 9/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

enum ParraDataSanitizer {
    // MARK: - Internal

    static func sanitize(httpHeaders: [String: String]) -> [String: String] {
        // If any of the known naughty header words either exactly match
        // any of the provided headers, or have a header that contains any of
        // the naughty words in part.

        return httpHeaders.filter { name, _ in
            let upperName = name.uppercased()

            if Constant.naughtyHeaders.contains(upperName) {
                return false
            }

            for header in Constant.naughtyHeaders {
                if upperName.contains(header) {
                    return false
                }
            }

            return true
        }
    }

    // MARK: - Private

    private enum Constant {
        static let naughtyHeaders = Set(
            [
                "AUTHORIZATION",
                "COOKIE",
                "FORWARDED",
                "PROXY-AUTHORIZATION",
                "REMOTE-ADDR",
                "SET-COOKIE",
                "API-KEY",
                "CSRF-TOKEN",
                "CSRFTOKEN",
                "FORWARDED-FOR",
                "REAL-IP",
                "XSRF-TOKEN",
                "AUTH",
                "TOKEN",
                "ACCESS",
                "KEY",
                "ID",
                "SECRET",
                "CREDENTIAL",
                "PASSWORD",
                "USER",
                "API"
            ]
        )
    }
}
