//
//  ParraLoggerThreadInfo+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerThreadInfo: ParraDictionaryConvertible {
    public var dictionary: [String : Any] {
        var params: [String: Any] = [
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

        if let callStackSymbols {
            switch callStackSymbols {
            case .raw(let array):
                params["stack_frames"] = array
            case .demangled(let array):
                params["stack_frames"] = array
            }
        }

        return params
    }
}
