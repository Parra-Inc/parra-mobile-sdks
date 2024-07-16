//
//  ForgotPasswordStateManager+ScreenState.swift
//  Parra
//
//  Created by Mick MacCallum on 7/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension ForgotPasswordStateManager {
    enum ScreenState: Equatable {
        case initial
        case codeSending
        case codeSent(rateLimited: Bool, error: Error?)
        case codeEntered(code: String)
        case complete

        // MARK: - Internal

        static func == (
            lhs: ScreenState,
            rhs: ScreenState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.initial, .initial), (.codeSending, .codeSending), (
                .complete,
                .complete
            ):
                return true
            case (.codeSent(let lrl, let le), .codeSent(let rrl, let re)):
                return lrl == rrl && le?.localizedDescription == re?
                    .localizedDescription
            case (.codeEntered(let lc), .codeEntered(let rc)):
                return lc == rc
            default:
                return false
            }
        }
    }
}
