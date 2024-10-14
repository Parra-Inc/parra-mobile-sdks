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

    enum State: Equatable, CustomDebugStringConvertible {
        case initial(ParraLaunchScreen.Options)
        case transitioning(LaunchActionsResult, ParraLaunchScreen.Options)
        case complete(LaunchActionsResult)
        case failed(ParraErrorWithUserInfo, () async -> Void)

        // MARK: - Internal

        var debugDescription: String {
            switch self {
            case .initial:
                return "initial"
            case .transitioning:
                return "transitioning"
            case .complete:
                return "complete"
            case .failed:
                return "failed"
            }
        }

        static func == (
            lhs: LaunchScreenStateManager.State,
            rhs: LaunchScreenStateManager.State
        ) -> Bool {
            switch (lhs, rhs) {
            case (.initial(let lOptions), .initial(let rOptions)):
                return lOptions == rOptions
            case (
                .transitioning(let lResult, let lOptions),
                .transitioning(let rResult, let rOptions)
            ):
                return lResult == rResult && lOptions == rOptions
            case (.complete(let lResult), .complete(let rResult)):
                return lResult == rResult
            case (.failed(let lErr, _), .failed(let rErr, _)):
                return lErr == rErr
            default:
                return false
            }
        }
    }

    private(set) var current: State

    func fail(
        userMessage: String,
        underlyingError: Error,
        tryAgain: @escaping () async -> Void
    ) {
        current = .failed(
            ParraErrorWithUserInfo(
                userMessage: userMessage,
                underlyingError: underlyingError
            ),
            tryAgain
        )
    }

    func dismiss(
        with result: LaunchActionsResult,
        launchScreenOptions: ParraLaunchScreen.Options
    ) {
        current = .transitioning(result, launchScreenOptions)
    }

    func complete(
        with result: LaunchActionsResult
    ) {
        current = .complete(result)
    }
}
