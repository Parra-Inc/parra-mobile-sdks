//
//  ParraSessionEvent.swift
//  ParraCore
//
//  Created by Mick MacCallum on 12/29/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraSessionEvent: Codable {
    let eventId: String

    /// The type of the event. Event properties should be consistent for each event name
    let name: String

    /// The date the event occurred
    let createdAt: Date

    let metadata: [String: AnyCodable]
}
