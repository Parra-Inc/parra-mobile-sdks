//
//  Data+prettyJson.swift
//  Parra
//
//  Created by Mick MacCallum on 7/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Data {
    func prettyPrintedJSONString() -> String {
        guard let object = try? JSONSerialization.jsonObject(
            with: self,
            options: []
        ) else {
            return "Failed to parse JSON data"
        }

        guard let data = try? JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted]
        ) else {
            return "Failed to re-serialize JSON object"
        }

        return String(data: data, encoding: .utf8) ??
            "Failed to convert JSON data to string"
    }
}
