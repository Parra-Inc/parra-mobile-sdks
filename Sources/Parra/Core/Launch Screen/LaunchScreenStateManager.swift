//
//  LaunchScreenStateManager.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

@MainActor
final class LaunchScreenStateManager: ObservableObject {
    // MARK: - Lifecycle

    init(state: State) {
        self.current = state
    }

    // MARK: - Internal

    enum State: Equatable {
        case initial(ParraLaunchScreen.Config)
        case transitioning(ParraAppInfo, ParraLaunchScreen.Config)
        case complete(ParraAppInfo)
        case failed(ParraErrorWithUserInfo)
    }

    @Published private(set) var current: State

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
        with appInfo: ParraAppInfo,
        launchScreenConfig: ParraLaunchScreen.Config
    ) {
        current = .transitioning(appInfo, launchScreenConfig)
    }

    func complete(
        with authInfo: ParraAppInfo
    ) {
        current = .complete(authInfo)
    }
}
