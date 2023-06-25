//
//  ParraSessionsResponse.swift
//  ParraCore
//
//  Created by Mick MacCallum on 4/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraSessionsResponse: Codable {
    public let shouldPoll: Bool
    /// ms
    public let retryDelay: Int
    public let retryTimes: Int
}
