//
//  ParraLoggerContext+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ParraLoggerContext: ParraDictionaryConvertible {
    public var dictionary: [String : Any] {
        var params: [String : Any] = [
            "module": module,
            "file_name": fileName
        ]

        if let fiberId {
            params["fiber_id"] = fiberId
        }

        if let fileExtension {
            params["file_extension"] = fileExtension
        }

        if let category {
            params["category"] = category
        }

        if !scopes.isEmpty {
            params["scopes"] = scopes.map { $0.name }
        }

        if let extra, !extra.isEmpty {
            params["extra"] = extra
        }

        return params
    }
}
