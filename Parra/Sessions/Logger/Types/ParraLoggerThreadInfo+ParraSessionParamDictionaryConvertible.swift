//
//  ParraLoggerThreadInfo+ParraSessionParamDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerThreadInfo: ParraSessionParamDictionaryConvertible {
    var paramDictionary: [String : Any] {
        var params: [String: Any] = [
            "id": id,
            "name": name,
            "queue_name": queueName,
            "stack_size": stackSize,
            "priority": priority,
            "quality_of_service": qualityOfService.loggerDescription
        ]

        if let callStackSymbols {
            params["call_stack_symbols"] = callStackSymbols
        }

        if let callStackReturnAddresses {
            params["call_stack_return_addresses"] = callStackReturnAddresses
        }

        return params
    }
}
