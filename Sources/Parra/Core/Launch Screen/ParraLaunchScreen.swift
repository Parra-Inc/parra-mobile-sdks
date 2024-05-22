//
//  ParraLaunchScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

public struct ParraLaunchScreen: View {
    // MARK: - Lifecycle

    init(
        config: Config
    ) {
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        renderLaunchScreen(by: config.type)
            .opacity(shouldFade ? 1 : 0)
            .onChange(
                of: launchScreenState.state,
                initial: true
            ) { _, newValue in
                if case .transitioning(let authInfo) = newValue, shouldFade {
                    withAnimation(.linear(duration: config.fadeDuration)) {
                        shouldFade = false
                    } completion: {
                        launchScreenState.complete(with: authInfo)
                    }
                }
            }
    }

    // MARK: - Private

    @EnvironmentObject private var launchScreenState: LaunchScreenStateManager

    @State private var shouldFade = true

    private let config: Config

    @ViewBuilder
    private func renderLaunchScreen(by type: LaunchScreenType) -> some View {
        switch type {
        case .default(let config):
            ParraDefaultLaunchScreen(config: config)
        case .storyboard(let config):
            ParraStoryboardLaunchScreen(config: config)
        case .custom(let view):
            AnyView(view)
        }
    }
}

#Preview {
    ParraLaunchScreen(
        config: ParraLaunchScreen.Config(
            type: LaunchScreenType.default(ParraDefaultLaunchScreen.Config()),
            fadeDuration: ParraLaunchScreen.Config.defaultFadeDuration
        )
    )
}
