//
//  ParraDefaultAuthenticationView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraDefaultAuthenticationView: View {
    // MARK: - Lifecycle

    public init(
        config: ParraAuthConfig = .default
    ) {
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        container
            .onAppear {
                let authService = parra.parraInternal.authService

                guard case .parraAuth = authService.authenticationMethod else {
                    fatalError(
                        "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
                    )
                }
            }
    }

    // MARK: - Internal

    @MainActor var container: some View {
        let container: AuthenticationWidget = parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager,
                    legalInfo: parra.parraInternal.appState.appInfo?
                        .legal ?? .empty
                ),
                config: config
            )

        return container
    }

    // MARK: - Private

    private let config: ParraAuthConfig

    @Environment(\.parra) private var parra
}
