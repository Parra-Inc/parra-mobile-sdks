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
        return httpHeaders.filter { name, _ in
            return !Constant.naughtyHeaders.contains(name.uppercased())
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
                "XSRF-TOKEN"
            ]
        )
    }
}
