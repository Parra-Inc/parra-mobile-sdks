//
//  ParraEventWrapper.swift
//  Parra
//
//  Created by Mick MacCallum on 6/25/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraEventWrapper: ParraEvent {
    var name: String
    var params: [String: Any]

    init(
        name: String,
        params: [String: Any] = [:]
    ) {
        self.params = params
        self.name = StringManipulators.snakeCaseify(
            text: name
        )
    }

    init(event: ParraEvent) {
        self.init(
            name: event.name,
            params: event.params
        )
    }

    // Partially redundant overload since ParraIternalEvent conforms to ParraEvent
    // but adding this allows us to pass interval event cases without fully qualifying them.
    init(event: ParraInternalEvent) {
        self.init(
            name: event.name,
            params: event.params
        )
    }

    init(
        event: ParraEvent,
        extraParams: [String: Any]
    ) {
        self.init(
            name: event.name,
            params: event.params.merging(extraParams) { $1 }
        )
    }
}
