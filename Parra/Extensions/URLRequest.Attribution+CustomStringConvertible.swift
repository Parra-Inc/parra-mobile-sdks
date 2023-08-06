//
//  URLRequest.Attribution+CustomStringConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 8/6/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension URLRequest.Attribution: CustomStringConvertible {
    public var description: String {
        switch self {
        case .developer:
            return "developer"
        case .user:
            return "user"
        @unknown default:
            return "unknown"
        }
    }
}
