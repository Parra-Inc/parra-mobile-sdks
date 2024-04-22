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

    public init() {
        let authService = parra.parraInternal.authService

        guard case .parraAuth = authService.authenticationMethod else {
            fatalError(
                "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
            )
        }
    }

    // MARK: - Public

    public var body: some View {
        AuthenticationWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: .init(),
            componentFactory: .init(global: .default, theme: .default),
            contentObserver: .init(
                initialParams: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager
                )
            )
        )
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}
