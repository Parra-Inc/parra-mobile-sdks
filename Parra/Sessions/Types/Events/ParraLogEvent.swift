//
//  ParraLogEvent.swift
//  Parra
//
//  Created by Mick MacCallum on 9/10/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraLogEvent: ParraDataEvent {
    var extra: [String : Any] {
        return logData.dictionary
    }

    let name: String = "log"
    let logData: ParraLogProcessedData

    internal init(logData: ParraLogProcessedData) {
        self.logData = logData
    }
}
