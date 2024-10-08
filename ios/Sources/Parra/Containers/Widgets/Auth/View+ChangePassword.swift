//
//  View+ChangePassword.swift
//  Parra
//
//  Created by Mick MacCallum on 7/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct ParraChangePasswordModal: View {
    // MARK: - Lifecycle

    init(
        config: ParraAuthDefaultForgotPasswordScreen.Config,
        complete: @escaping () -> Void
    ) {
        self.config = config
        self.complete = complete
    }

    // MARK: - Internal

    let config: ParraAuthDefaultForgotPasswordScreen.Config
    let complete: () -> Void

    var body: some View {
        NavigationStack(path: $navigationState.navigationPath) {
            content.environment(navigationState)
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var parraAuthState
    @Environment(\.parraTheme) private var parraTheme

    @State private var navigationState = NavigationState()

    @ViewBuilder
    @MainActor private var content: some View {
        switch parraAuthState {
        case .authenticated(let user), .anonymous(let user):
            if let email = user.info.email {
                let params = ParraAuthDefaultForgotPasswordScreen.Params(
                    identity: email,
                    codeLength: 6,
                    sendConfirmationCode: {
                        let responseCode = try await parra.parraInternal.authService
                            .forgotPassword(
                                identity: email,
                                identityType: .email
                            )

                        // received rate limit proxied through sms/email service
                        return ParraForgotPasswordResponse(
                            rateLimited: responseCode == 429
                        )
                    },
                    updatePassword: { code, newPassword in
                        try await parra.parraInternal.authService.resetPassword(
                            code: code,
                            password: newPassword
                        )
                    },
                    complete: complete
                )

                ParraAuthDefaultForgotPasswordScreen(
                    params: params,
                    config: config
                )
                .padding(.top, 34)
                .background(parraTheme.palette.primaryBackground)
            } else {
                EmptyView()
            }
        default:
            EmptyView()
        }
    }
}

public extension View {
    /// Presents a modal sheet to allow the current user to update their
    /// password. Only available if you're using Parra Auth.
    @MainActor
    func presentParraChangePasswordWidget(
        isPresented: Binding<Bool>,
        config: ParraAuthDefaultForgotPasswordScreen.Config = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentSheet(
            isPresented: isPresented,
            content: {
                ParraChangePasswordModal(
                    config: config,
                    complete: {
                        isPresented.wrappedValue = false
                    }
                )
            },
            onDismiss: onDismiss
        )
    }
}
