//
//  Endpoint.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol Endpoint {
    var slug: String { get }
    var method: HttpMethod { get }
    /// Whether extra session tracking information should be attached to the
    /// request headers.
    var isTrackingEnabled: Bool { get }
}

extension Endpoint {
    var displayName: String {
        return "\(method.rawValue.uppercased()) \(slug)"
    }
}
