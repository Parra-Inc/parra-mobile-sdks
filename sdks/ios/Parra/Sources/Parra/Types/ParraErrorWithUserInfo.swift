//
//  ParraErrorWithUserInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraErrorWithUserInfo: Equatable {
    // MARK: - Public

    public static func == (
        lhs: ParraErrorWithUserInfo,
        rhs: ParraErrorWithUserInfo
    ) -> Bool {
        return lhs.userMessage == rhs.userMessage
            && lhs.underlyingError.localizedDescription == rhs.underlyingError
            .localizedDescription
    }

    // MARK: - Internal

    let userMessage: String
    let underlyingError: Error
}
