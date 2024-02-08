//
//  ParraSessionsResponse.swift
//  Parra
//
//  Created by Mick MacCallum on 4/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraSessionsResponse: Codable {
    let shouldPoll: Bool
    /// ms
    let retryDelay: Int
    let retryTimes: Int
}
