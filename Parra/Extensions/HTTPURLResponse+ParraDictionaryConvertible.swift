//
//  HTTPURLResponse+ParraDictionaryConvertible.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension HTTPURLResponse: ParraSanitizedDictionaryConvertible {
    var sanitized: ParraSanitizedDictionary {
        var params: [String : Any] = [
            "status_code": statusCode,
            "expected_content_length": expectedContentLength
        ]

        if let url {
            params["url"] = url.absoluteString
        }

        if let mimeType {
            params["mime_type"] = mimeType
        }

        if let headers = allHeaderFields as? [String : String] {
            params["headers"] = ParraDataSanitizer.sanitize(
                httpHeaders: headers
            )
        }

        if let suggestedFilename {
            params["suggested_filename"] = suggestedFilename
        }

        if let textEncodingName {
            params["text_encoding_name"] = textEncodingName
        }

        return ParraSanitizedDictionary(dictionary: params)
    }
}
