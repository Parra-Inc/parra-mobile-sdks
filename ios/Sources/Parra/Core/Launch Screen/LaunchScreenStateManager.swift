//
//  LaunchScreenStateManager.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

@MainActor
@Observable
final class LaunchScreenStateManager {
    // MARK: - Lifecycle

    init(state: State) {
        self.current = state
    }

    // MARK: - Internal

    enum State: Equatable {
        case initial(ParraLaunchScreen.Config)
        case transitioning(LaunchActionsResult, ParraLaunchScreen.Config)
        case complete(LaunchActionsResult)
        case failed(ParraErrorWithUserInfo)
    }

    private(set) var current: State

    func fail(
        userMessage: String,
        underlyingError: Error
    ) {
        current = .failed(
            ParraErrorWithUserInfo(
                userMessage: userMessage,
                underlyingError: underlyingError
            )
        )
    }

    func dismiss(
        with result: LaunchActionsResult,
        launchScreenConfig: ParraLaunchScreen.Config
    ) {
        current = .transitioning(result, launchScreenConfig)
    }

    func complete(
        with result: LaunchActionsResult
    ) {
        current = .complete(result)
    }
}
