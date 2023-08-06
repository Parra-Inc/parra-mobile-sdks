//
//  ParraErrorWithExtra.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

internal struct ParraErrorWithExtra {
    let message: String
    let extra: [String : Any]

    internal init(message: String, extra: [String : Any]) {
        self.message = message
        self.extra = extra
    }

    internal init(parraError: ParraError) {
        self.message = parraError.errorDescription
        self.extra = parraError.dictionary
    }

    internal init(error: Error) {
        // Error is always bridged to NSError, can't downcast to check.
        if type(of: error) is NSError.Type {
            let nsError = error as NSError

            var extra = nsError.userInfo
            extra["domain"] = nsError.domain
            extra["code"] = nsError.code

            self.message = nsError.localizedDescription
            self.extra = extra
        } else {
            // It is important to include a reflection of Error conforming types in order to actually identify which
            // error enum they belond to. This information is not provided by their descriptions.
            self.message = "\(String(reflecting: error)), description: \(error.localizedDescription)"
            self.extra = [:]
        }
    }
}
