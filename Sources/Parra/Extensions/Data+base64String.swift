//
//  Data+base64String.swift
//  Parra
//
//  Created by Mick MacCallum on 7/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension Data {
    func base64urlEncodedString() -> String {
        var result = base64EncodedString()

        result = result.replacingOccurrences(of: "+", with: "-")
        result = result.replacingOccurrences(of: "/", with: "_")
        result = result.replacingOccurrences(of: "=", with: "")

        return result
    }

    init?(base64urlEncoded input: String) {
        var base64 = input
        base64 = base64.replacingOccurrences(of: "-", with: "+")
        base64 = base64.replacingOccurrences(of: "_", with: "/")
        while base64.count % 4 != 0 {
            base64 = base64.appending("=")
        }
        self.init(base64Encoded: base64)
    }
}
