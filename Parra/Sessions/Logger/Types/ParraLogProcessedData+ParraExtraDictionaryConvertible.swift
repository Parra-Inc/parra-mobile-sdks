//
//  ParraLogProcessedData+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLogProcessedData: ParraDictionaryConvertible {
    var dictionary: [String: Any] {
        var params: [String: Any] = [
            "timestamp": date.timeIntervalSince1970,
            "level": level.loggerDescription,
            "message": message,
            "call_site_file_name": callSiteFileName,
            "call_site_module": callSiteModule,
            "call_site_function": callSiteFunction,
            "call_site_line": callSiteLine,
            "call_site_column": callSiteColumn,
        ]

        if let context {
            params["context"] = context.dictionary
        }

        if !extra.isEmpty {
            params["extra"] = extra
        }

        let threadInfoDict = threadInfo.dictionary
        if !threadInfoDict.isEmpty {
            params["thread_info"] = threadInfoDict
        }

        return params
    }
}

