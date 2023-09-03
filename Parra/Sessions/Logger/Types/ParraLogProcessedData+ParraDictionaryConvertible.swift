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
                "module": callSiteModule,
                "file_name": callSiteFileName,
                "file_extension": callSiteFileName,
                "function": callSiteFunction,
                "line": callSiteLine,
                "column": callSiteColumn
            ] as [String : Any]
        ]

        if let loggerContext {
            params["logger_context"] = loggerContext.dictionary
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

