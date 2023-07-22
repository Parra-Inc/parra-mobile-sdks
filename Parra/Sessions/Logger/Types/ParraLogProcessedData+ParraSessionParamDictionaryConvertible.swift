//
//  ParraLogProcessedData+ParraSessionParamDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLogProcessedData: ParraSessionParamDictionaryConvertible {
    var paramDictionary: [String : Any] {
        var params: [String: Any] = [
            "timestamp": date.timeIntervalSince1970,
            "level": level.loggerDescription,
            "message": message,
            "call_site_file_name": callSiteFileName,
            "call_site_module": callSiteModule
        ]

        let contextDict = context?.paramDictionary ?? [:]
        if !contextDict.isEmpty {
            params["context"] = contextDict
        }

        if !extra.isEmpty {
            params["extra"] = extra
        }

        let threadInfoDict = threadInfo.paramDictionary
        if !threadInfoDict.isEmpty {
            params["thread_info"] = threadInfoDict
        }

        return params
    }
}

