//
//  ParraErrorWithExtra.swift
//  Parra
//
//  Created by Mick MacCallum on 8/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

struct ParraErrorWithExtra {
    // MARK: - Lifecycle

    init(
        message: String,
        extra: [String: Any]?
    ) {
        self.message = message
        self.extra = extra
    }

    init(parraError: ParraError) {
        self.message = parraError.errorDescription
        self.extra = parraError.sanitized.dictionary
    }

    init(error: Error) {
        let (message, extra) = LoggerFormatters.extractMessage(
            from: error
        )

        self.message = message
        self.extra = extra
    }

    // MARK: - Internal

    let message: String
    let extra: [String: Any]?
}
