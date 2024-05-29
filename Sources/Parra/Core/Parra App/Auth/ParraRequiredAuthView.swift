//
//  ParraRequiredAuthView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraRequiredAuthView<
    AuthenticatedContent, UnauthenticatedContent
>: ParraAppContent where AuthenticatedContent: View,
    UnauthenticatedContent: ParraAuthenticationFlow
{
    // MARK: - Lifecycle

    public init(
        authenticatedContent: @escaping (
            _ user: ParraUser
        ) -> AuthenticatedContent,
        unauthenticatedContent: @escaping (
            _ appInfo: ParraAppInfo
        ) -> UnauthenticatedContent
    ) {
        self.authenticatedContent = authenticatedContent
        self.unauthenticatedContent = unauthenticatedContent
    }

    // MARK: - Public

    public let unauthenticatedContent: (
        _ appInfo: ParraAppInfo
    ) -> UnauthenticatedContent

    public var body: some View {
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

    public func authenticatedContent(
        for user: ParraUser
    ) -> AuthenticatedContent {
        return authenticatedContent(user)
    }

    public func unauthenticatedContent(
        with appInfo: ParraAppInfo
    ) -> UnauthenticatedContent {
        var authView = unauthenticatedContent(appInfo)

        authView.delegate = self

        return authView
    }

    // MARK: - Internal

    @Environment(\.parra) var parra
    @EnvironmentObject var parraAuthState: ParraAuthState
    @EnvironmentObject var parraAppInfo: ParraAppInfo

    @ViewBuilder var content: some View {
        switch currentUserMirror {
        case .authenticated(let user):
            authenticatedContent(for: user)
        case .unauthenticated:
            unauthenticatedContent(parraAppInfo)
                .transition(
                    .push(from: .top)
                        .animation(.easeIn(duration: 0.35))
                )
        }
    }

    // MARK: - Private

    private var authenticatedContent: (
        _ user: ParraUser
    ) -> AuthenticatedContent

    @State private var currentUserMirror: ParraAuthResult =
        .unauthenticated(nil)
}

// MARK: ParraAuthenticationFlowDelegate

extension ParraRequiredAuthView: ParraAuthenticationFlowDelegate {
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
