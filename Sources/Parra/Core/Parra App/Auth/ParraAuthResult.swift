//
//  ParraAuthResult.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public enum ParraAuthResult: Equatable {
    case undetermined
    case authenticated(ParraUser)
    case unauthenticated(Error?)

    // MARK: - Public

    public static func == (
        lhs: ParraAuthResult,
        rhs: ParraAuthResult
    ) -> Bool {
        switch (lhs, rhs) {
        case (.undetermined, .undetermined):
            return true
        case (.authenticated(let lhsUser), .authenticated(let rhsUser)):
            return lhsUser == rhsUser
        case (.unauthenticated(let lhsError), .unauthenticated(let rhsError)):
            return lhsError?.localizedDescription == rhsError?
                .localizedDescription
        default:
            return false
        }
    }
}
