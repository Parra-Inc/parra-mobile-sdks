//
//  ParraRequiredAuthWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraRequiredAuthWindow<
    AuthenticatedContent, UnauthenticatedContent
>: ParraAppContent where AuthenticatedContent: View,
    UnauthenticatedContent: ParraAuthenticationFlow
{
    // MARK: - Lifecycle

    public init(
        authenticatedContent: @escaping (
            _ user: ParraUser
        ) -> AuthenticatedContent,
        unauthenticatedContent: @escaping () -> UnauthenticatedContent
    ) {
        self.authenticatedContent = authenticatedContent
        self.unauthContent = unauthenticatedContent
    }

    // MARK: - Public

    public var body: some View {
        LaunchScreenWindow {
            content
                .onChange(
                    of: parraAuthState.current,
                    initial: true
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
    }

    public func authenticatedContent(
        for user: ParraUser
    ) -> AuthenticatedContent {
        return authenticatedContent(user)
    }

    public func unauthenticatedContent() -> UnauthenticatedContent {
        var authView = unauthContent()

        authView.delegate = self

        return authView
    }

    // MARK: - Internal

    @Environment(\.parra) var parra
    @EnvironmentObject var parraAuthState: ParraAuthState

    @ViewBuilder var content: some View {
        switch currentUserMirror {
        case .authenticated(let user):
            authenticatedContent(for: user)
        case .unauthenticated:
            unauthenticatedContent()
                .transition(
                    .push(from: .top)
                        .animation(.easeIn(duration: 0.35))
                )
        }
    }

    // MARK: - Private

    private let authenticatedContent: (
        _ user: ParraUser
    ) -> AuthenticatedContent

    private let unauthContent: () -> UnauthenticatedContent

    @State private var currentUserMirror: ParraAuthResult =
        .unauthenticated(nil)
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
