//
//  ParraSessionsResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSessionsResponse: Codable {
    internal let shouldPoll: Bool
    /// ms
    internal let retryDelay: Int
    internal let retryTimes: Int
}
