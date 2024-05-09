//
//  ParraRequiredAuthView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraRequiredAuthView<
    AuthenticatedContent
>: ParraAppContent where AuthenticatedContent: View {
    // MARK: - Lifecycle

    public init(
        authenticatedContent: @escaping (
            _ user: ParraUser
        ) -> AuthenticatedContent,
        authenticationFlowConfig: ParraAuthenticationFlowConfig = .default
    ) {
        self.authenticatedContent = authenticatedContent
        self.authenticationFlowConfig = authenticationFlowConfig
    }

    // MARK: - Public

    @ViewBuilder public var authenticatedContent: (
        _ user: ParraUser
    ) -> AuthenticatedContent

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
        for error: Error?
    ) -> ParraAuthenticationFlowView {
        return ParraAuthenticationFlowView(
            flowConfig: authenticationFlowConfig
        )
    }

    // MARK: - Internal

    @EnvironmentObject var parraAuthState: ParraAuthState

    @ViewBuilder var content: some View {
        switch currentUserMirror {
        case .authenticated(let user):
            authenticatedContent(for: user)
        case .unauthenticated(let error):
            unauthenticatedContent(for: error)
                .transition(
                    .push(from: .top)
                        .animation(.easeIn(duration: 0.35))
                )
        }
    }

    // MARK: - Private

    private let authenticationFlowConfig: ParraAuthenticationFlowConfig

    @State private var currentUserMirror: ParraAuthResult =
        .unauthenticated(nil)
}
