//
//  HTTPURLResponse+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension HTTPURLResponse: ParraDictionaryConvertible {
    var dictionary: [String : Any] {
        var dict: [String : Any] = [
            "status_code": statusCode,
            "headers": allHeaderFields,
            "expected_content_length": expectedContentLength,
        ]

        if let url {
            dict["url"] = url.absoluteString
        }

        if let mimeType {
            dict["mime_type"] = mimeType
        }

        if let suggestedFilename {
            dict["suggested_filename"] = suggestedFilename
        }

        if let textEncodingName {
            dict["text_encoding_name"] = textEncodingName
        }

        return dict
    }
}
