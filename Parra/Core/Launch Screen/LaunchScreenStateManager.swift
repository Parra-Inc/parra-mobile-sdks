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
        case transitioning
        case complete

        // MARK: - Internal

        var showLaunchScreen: Bool {
            return self == State.initial || self == State.transitioning
        }

        var shouldAppContent: Bool {
            return self == State.transitioning || self == State.complete
        }
    }

    @MainActor @Published private(set) var state: State = .initial

    @MainActor
    func dismiss() {
        state = .transitioning
    }

    @MainActor
    func complete() {
        state = .complete
    }
}
