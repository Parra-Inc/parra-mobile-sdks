//
//  ParraLogEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

@usableFromInline
internal struct ParraLogEvent: ParraDataEvent {
    @usableFromInline
    var extra: [String : Any] {
        return logData.sanitized.dictionary
    }

    @usableFromInline
    let name: String = "log"

    let logData: ParraLogProcessedData

    internal init(logData: ParraLogProcessedData) {
        self.logData = logData
    }
}
