//
//  SheetLoadState.swift
//  Parra
//
//  Created by Mick MacCallum on 7/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

enum SheetLoadState<StateData: Equatable>: Equatable {
    // Initial state. Standing by and waiting for start signal
    case ready
    // Start signal received. In this state until complete or error
    case started
    case complete(StateData)
    case error(Error)

    // MARK: - Internal

    static func == (
        lhs: SheetLoadState<StateData>,
        rhs: SheetLoadState<StateData>
    ) -> Bool {
        switch (lhs, rhs) {
        case (.ready, .ready), (.started, .started):
            return true
        case (.complete(let lc), .complete(let rc)):
            return lc == rc
        case (.error(let le), .error(let re)):
            return le.localizedDescription == re.localizedDescription
        default:
            return false
        }
    }
}
