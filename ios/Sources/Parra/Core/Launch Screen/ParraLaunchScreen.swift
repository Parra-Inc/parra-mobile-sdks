//
//  ParraLaunchScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

public struct ParraLaunchScreen: View, Equatable {
    // MARK: - Lifecycle

    init(
        options: Options
    ) {
        self.options = options
    }

    // MARK: - Public

    public var body: some View {
        renderLaunchScreen
            .opacity(shouldFade ? 1 : 0)
            .onChange(
                of: launchScreenState.current,
                initial: true
            ) { _, newValue in
                if case .transitioning(let result, _) = newValue, shouldFade {
                    withAnimation(.linear(duration: options.fadeDuration)) {
                        shouldFade = false
                    } completion: {
                        launchScreenState.complete(with: result)
                    }
                }
            }
    }

    public static func == (
        lhs: ParraLaunchScreen,
        rhs: ParraLaunchScreen
    ) -> Bool {
        return lhs.options == rhs.options
    }

    // MARK: - Private

    @Environment(LaunchScreenStateManager.self) private var launchScreenState

    @State private var shouldFade = true

    private let options: Options

    @ViewBuilder private var renderLaunchScreen: some View {
        switch options.type {
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
        options: ParraLaunchScreen.Options(
            type: ParraLaunchScreenType.default(ParraDefaultLaunchScreen.Config()),
            fadeDuration: ParraLaunchScreen.Options.defaultFadeDuration
        )
    )
}
