//
//  ParraLogProcessedData+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLogProcessedData: ParraDictionaryConvertible {
    var dictionary: [String : Any] {
        var params: [String : Any] = [
            "level": level.loggerDescription,
            "message": message,
            "call_site": [
                "file_name": callSiteFileName,
                "module": callSiteModule,
                "function": callSiteFunction,
                "line": callSiteLine,
                "column": callSiteColumn,
            ] as [String : Any]
        ]

        if let context {
            params["context"] = context.dictionary
        }

        if !extra.isEmpty {
            params["extra"] = extra
        }

        let threadInfoDict = threadInfo.dictionary
        if !threadInfoDict.isEmpty {
            params["thread"] = threadInfoDict
        }

        return params
    }
}

