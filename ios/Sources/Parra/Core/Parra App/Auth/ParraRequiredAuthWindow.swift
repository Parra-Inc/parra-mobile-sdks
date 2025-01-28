//
//  ParraRequiredAuthWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
public struct ParraRequiredAuthWindow<
    AuthenticatedContent, UnauthenticatedContent
>: ParraAppContent where AuthenticatedContent: View,
    UnauthenticatedContent: ParraAuthenticationFlow
{
    // MARK: - Lifecycle

    public init(
        authenticatedContent: @escaping @MainActor () -> AuthenticatedContent,
        unauthenticatedContent: @escaping @MainActor () -> UnauthenticatedContent = {
            return ParraDefaultAuthenticationFlowView()
        }
    ) {
        self.authContent = authenticatedContent
        self.unauthContent = unauthenticatedContent
    }

    // MARK: - Public

    public var body: some View {
        LaunchScreenWindow {
            content
        }
    }

    public func authenticatedContent() -> AuthenticatedContent {
        return authContent()
    }

    public func unauthenticatedContent() -> UnauthenticatedContent {
        var authView = unauthContent()

        authView.delegate = self

        return authView
    }

    // MARK: - Internal

    @Environment(\.parra) var parra

    @ViewBuilder var content: some View {
        switch parraAuthState {
        case .undetermined:
            EmptyView()
        case .authenticated:
            authenticatedContent()
        case .guest, .anonymous:
            unauthenticatedContent()
                .environment(parra)
                .transition(
                    .push(from: .top)
                        .animation(.easeIn(duration: 0.35))
                )
        }
    }

    // MARK: - Private

    @Environment(\.parraAuthState) private var parraAuthState

    private let authContent: () -> AuthenticatedContent
    private let unauthContent: () -> UnauthenticatedContent
}

// MARK: ParraAuthenticationFlowDelegate

extension ParraRequiredAuthWindow: ParraAuthenticationFlowDelegate {
    public func completeAuthentication(
        with user: ParraUser
    ) {
        Task {
            await parra.parraInternal.authService.applyUserUpdate(
                .authenticated(user)
            )
        }
    }
}
