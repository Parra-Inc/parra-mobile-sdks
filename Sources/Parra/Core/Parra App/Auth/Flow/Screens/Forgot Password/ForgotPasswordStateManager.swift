//
//  ForgotPasswordStateManager.swift
//  Parra
//
//  Created by Mick MacCallum on 7/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

final class ForgotPasswordStateManager: ObservableObject {
    // MARK: - Lifecycle

    init(
        params: ParraAuthDefaultForgotPasswordScreen.Params
    ) {
        self.params = params
    }

    // MARK: - Internal

    @Published private(set) var screen = ScreenState.initial

    func sendCode() {
        transition(to: .codeSending)

        Task {
            do {
                let result = try await params.sendConfirmationCode()

                transition(
                    to: .codeSent(
                        rateLimited: result.rateLimited,
                        error: nil
                    )
                )
            } catch {
                transition(
                    to: .codeSent(
                        rateLimited: false,
                        error: error
                    )
                )
            }
        }
    }

    func submitCode(_ code: String) {
        transition(
            to: .codeEntered(code: code)
        )
    }

    func submitNewPassword(
        _ code: String,
        _ password: String
    ) async throws {
        try await params.updatePassword(code, password)

        transition(
            to: .complete
        )
    }

    func complete() {
        params.complete()
    }

    // MARK: - Private

    private let params: ParraAuthDefaultForgotPasswordScreen.Params

    private func transition(to state: ScreenState) {
        Logger.trace("Forgot password transitioning to state", [
            "state": String(describing: state)
        ])

        Task { @MainActor in
            withAnimation {
                screen = state
            }
        }
    }
}
