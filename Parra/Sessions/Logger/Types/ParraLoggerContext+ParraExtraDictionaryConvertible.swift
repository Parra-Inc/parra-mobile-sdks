//
//  ParraLoggerContext+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerContext: ParraDictionaryConvertible {
    public var dictionary: [String: Any] {
        var params: [String: Any] = [
            "module": module,
            "file_name": fileName,
            "categories": categories
        ]

        if !extra.isEmpty {
            params["extra"] = extra
        }

        return params
    }
}
