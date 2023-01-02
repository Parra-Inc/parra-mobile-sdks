//
//  ParraSessionEvent.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraSessionEvent: Codable {
    public let eventId: String

    /// The type of the event. Event properties should be consistent for each event name
    public let name: String

    /// The date the event occurred
    public let createdAt: Date

    public let metadata: [String: AnyCodable]
}
