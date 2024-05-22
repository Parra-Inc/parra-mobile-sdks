//
//  LaunchScreenStateManager.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

final class LaunchScreenStateManager: ObservableObject {
    enum State: Equatable {
        case initial
        case transitioning(ParraAppAuthInfo)
        case complete(ParraAppAuthInfo)

        // MARK: - Internal

        var showLaunchScreen: Bool {
            switch self {
            case .initial, .transitioning:
                return true
            case .complete:
                return false
            }
        }

        var showAppContent: Bool {
            switch self {
            case .transitioning, .complete:
                return true
            case .initial:
                return false
            }
        }
    }

    @MainActor @Published private(set) var state: State = .initial

    @MainActor
    func dismiss(
        with authInfo: ParraAppAuthInfo
    ) {
        state = .transitioning(authInfo)
    }

    @MainActor
    func complete(
        with authInfo: ParraAppAuthInfo
    ) {
        state = .complete(authInfo)
    }
}
