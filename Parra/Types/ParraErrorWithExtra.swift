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
    let extra: [String : Any]?

    internal init(
        message: String,
        extra: [String : Any]?
    ) {
        self.message = message
        self.extra = extra
    }

    internal init(parraError: ParraError) {
        self.message = parraError.errorDescription
        self.extra = parraError.sanitized.dictionary
    }

    internal init(error: Error) {
        let (message, extra) = LoggerFormatters.extractMessage(
            from: error
        )

        self.message = message
        self.extra = extra
    }
}
