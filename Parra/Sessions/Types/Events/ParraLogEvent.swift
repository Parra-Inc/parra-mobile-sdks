//
//  ParraLogEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@usableFromInline
struct ParraLogEvent: ParraDataEvent {
    // MARK: - Lifecycle

    init(logData: ParraLogProcessedData) {
        self.logData = logData
    }

    // MARK: - Internal

    @usableFromInline let name: String = "log"

    let logData: ParraLogProcessedData

    @usableFromInline var extra: [String: Any] {
        return logData.sanitized.dictionary
    }
}
