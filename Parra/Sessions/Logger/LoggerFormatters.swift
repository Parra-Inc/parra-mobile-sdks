//
//  LoggerFormatters.swift
//  Parra
//
//  Created by Mick MacCallum on 8/14/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct LoggerFormatters {
    
    internal static func extractMessage(
        from error: Error
    ) -> (message: String, extra: [String : Any]?) {

        // Errors when JSON encoding/decoding fails
        if let encodingError = error as? EncodingError {
            switch encodingError {
            case .invalidValue(let value, let context):
                let aggregatePath = context.codingPath.map { path in
                    if let intValue = path.intValue {
                        return "[\(intValue)]"
                    }

                    return path.stringValue
                }.joined(separator: ".")

                var extra: [String : Any] = [
                    "coding_path": context.codingPath
                ]

                if let underlyingError = context.underlyingError {
                    extra["underlying_error"] = underlyingError.localizedDescription
                }

                return (
                    message: "\(context.debugDescription). Keypath: \(aggregatePath) Error: \(value)",
                    extra: nil
                )
            @unknown default:
                break
            }
        }

        // Error is always bridged to NSError, can't downcast to check.
        if type(of: error) is NSError.Type {
            let nsError = error as NSError

            var extra = nsError.userInfo
            extra["domain"] = nsError.domain
            extra["code"] = nsError.code

            return (
                message: nsError.localizedDescription,
                extra: extra
            )
        }

        // It is important to include a reflection of Error conforming types in order to actually identify which
        // error enum they belond to. This information is not provided by their descriptions.
        return (
            message: "\(String(reflecting: error)), description: \(error.localizedDescription)",
            extra: nil
        )
    }
}
