//
//  ParraLoggerThreadInfo+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerThreadInfo: ParraSanitizedDictionaryConvertible {
    public var sanitized: ParraSanitizedDictionary {
        var params: [String : Any] = [
            "id": id,
            "queue_name": queueName,
            "stack_size": stackSize,
            "priority": priority,
            "qos": qualityOfService.loggerDescription
        ]

        if let threadName {
            params["name"] = threadName
        }

        if let threadNumber {
            params["number"] = threadNumber
        }

        switch callStackSymbols {
        case .raw(let array):
            params["stack_frames"] = array
        case .demangled(let array):
            params["stack_frames"] = array
        case .none:
            // No symbols, don't set the key
            break
        }

        return ParraSanitizedDictionary(dictionary: params)
    }
}
