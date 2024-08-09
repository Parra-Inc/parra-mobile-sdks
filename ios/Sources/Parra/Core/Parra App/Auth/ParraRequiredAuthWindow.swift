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
                    of: parraAuthState,
                    initial: true
                ) { oldValue, newValue in
                    switch (oldValue, newValue) {
                    case
                        (.guest, .authenticated),
                        (.undetermined, .authenticated),
                        (.error, .authenticated):
                        withAnimation {
                            authStateMirror = newValue
                        }
                    default:
                        authStateMirror = newValue
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

    @ViewBuilder var content: some View {
        switch authStateMirror {
        case .undetermined:
            EmptyView()
        case .authenticated(let user):
            authenticatedContent(for: user)
        case .guest, .error, .anonymous:
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

    private let authenticatedContent: (
        _ user: ParraUser
    ) -> AuthenticatedContent

    private let unauthContent: () -> UnauthenticatedContent

    @State private var authStateMirror: ParraAuthState = .undetermined
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
