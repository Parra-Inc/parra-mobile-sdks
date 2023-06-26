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
    var params: [String : Any]

    init(name: String, params: [String : Any] = [:]) {
        self.name = StringManipulators.snakeCaseify(text: name)
        self.params = params
    }

    init(event: ParraEvent) {
        self.init(
            name: event.name,
            params: event.params
        )
    }

    init(event: ParraEvent, extraParams: [String: Any]) {
        self.init(
            name: event.name,
            params: event.params.merging(extraParams) { $1 }
        )
    }
}
