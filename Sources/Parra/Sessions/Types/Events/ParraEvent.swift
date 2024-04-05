//
//  ParraEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public protocol ParraEvent {
    /// A unique name for the event. Event names should be all lowercase and in_snake_case.
    var name: String { get }
}

public protocol ParraDataEvent: ParraEvent {
    var extra: [String: Any] { get }
}

public struct ParraBasicEvent: ParraEvent {
    // MARK: - Lifecycle

    public init(name: String) {
        self.name = name
    }

    // MARK: - Public

    public var name: String
}

public struct ParraBasicDataEvent: ParraDataEvent {
    // MARK: - Lifecycle

    public init(
        name: String,
        extra: [String: Any]
    ) {
        self.name = name
        self.extra = extra
    }

    // MARK: - Public

    public var name: String
    public var extra: [String: Any]
}
