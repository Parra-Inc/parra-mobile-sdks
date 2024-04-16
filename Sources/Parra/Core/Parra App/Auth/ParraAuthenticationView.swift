//
//  ParraAuthenticationView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

/// The login screen for the Parra app.
public struct ParraAuthenticationView: View {
    // MARK: - Lifecycle

    public init(error: Error? = nil) {
        self.error = error
    }

    // MARK: - Public

    public var body: some View {
        VStack(spacing: 12) {
            Spacer()

            TextField(text: $email, prompt: Text("Email address")) {
                Text("yeah")
            }
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)

            SecureField(text: $password, prompt: Text("Password")) {
                Text("yeah yeah")
            }
            .textInputAutocapitalization(.never)

            Button("Log in") {
                Task {
                    do {
                        try await parra.parraInternal.authService.login(
                            username: email,
                            password: password
                        )
                    } catch {
                        Logger.error(error)
                    }
                }
            }

            Spacer()
        }
        .safeAreaPadding()
    }

    // MARK: - Internal

    var error: Error?

    // MARK: - Private

    @State private var email: String = "mickm@hey.com"
    @State private var password: String = "efhG5wefy"

    @Environment(\.parra) private var parra
}

#Preview {
    ParraAuthenticationView()
}
