//
//  ParraCardModalViewedEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraCardModalViewedEvent: ParraDataEvent {
    // MARK: - Lifecycle

    init(modalType: ParraCardModalType) {
        self.name = modalType.eventName
        self.extra = [
            "type": modalType.rawValue
        ]
    }

    // MARK: - Internal

    var name: String
    var extra: [String: Any]
}
