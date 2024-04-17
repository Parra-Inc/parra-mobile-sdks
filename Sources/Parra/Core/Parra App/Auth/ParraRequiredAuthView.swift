//
//  ParraRequiredAuthView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraDefaultAuthenticationView: View {
    // MARK: - Lifecycle

    public init(error: Error? = nil) {
        self.error = error
    }

    // MARK: - Public

    public var error: Error?

    public var body: some View {
        let authService = parra.parraInternal.authService
        if !authService.authenticationMethod.supportsParraLoginScreen {
            fatalError(
                "ParraAuthenticationView used with an unsupported authentication method. If you want to use ParraAuthenticationView, you need to specify the ParraAuthenticationMethod as .parraAuth in the Parra configuration."
            )
        }

        AuthenticationWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: .init(),
            componentFactory: .init(global: .default, theme: .default),
            contentObserver: .init(
                initialParams: .init(
                    error: nil,
                    authService: parra.parraInternal.authService
                )
            )
        )
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
}

public struct ParraRequiredAuthView<
    AuthenticatedContent, UnauthenticatedContent
>: ParraAppContent where AuthenticatedContent: View,
    UnauthenticatedContent: View
{
    // MARK: - Lifecycle

    public init(
        authenticatedContent: @escaping (_ user: ParraUser)
            -> AuthenticatedContent,
        unauthenticatedContent: @escaping (_ error: Error?)
            -> UnauthenticatedContent = { error in
                ParraDefaultAuthenticationView(error: nil)
            }
    ) {
        self.authenticatedContent = authenticatedContent
        self.unauthenticatedContent = unauthenticatedContent
    }

    // MARK: - Public

    @ViewBuilder public var authenticatedContent: (_ user: ParraUser)
        -> AuthenticatedContent
    @ViewBuilder public var unauthenticatedContent: (_ error: Error?)
        -> UnauthenticatedContent

    public var body: some View {
        let result = switch currentUserMirror {
        case .authenticated(let user):
            AnyView(authenticatedContent(for: user))
        case .unauthenticated(let error):
            AnyView(
                unauthenticatedContent(for: error)
                    .transition(
                        .push(from: .top)
                            .animation(.easeIn(duration: 0.35))
                    )
            )
        }

        result
            .onAppear {
                currentUserMirror = authState.current
            }
            .onChange(
                of: authState.current
            ) { oldValue, newValue in
                switch (oldValue, newValue) {
                case (.unauthenticated, .authenticated):
                    withAnimation {
                        currentUserMirror = newValue
                    }
                default:
                    currentUserMirror = newValue
                }
            }
    }

    public func authenticatedContent(for user: ParraUser)
        -> AuthenticatedContent
    {
        return authenticatedContent(user)
    }

    public func unauthenticatedContent(for error: Error?)
        -> UnauthenticatedContent
    {
        return unauthenticatedContent(error)
    }

    // MARK: - Internal

    @Environment(\.parraAuthState) var authState

    // MARK: - Private

    @State private var currentUserMirror: ParraAuthResult =
        .unauthenticated(nil)
}
