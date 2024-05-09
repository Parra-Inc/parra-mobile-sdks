//
//  ParraAuthDefaultPasswordInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAuthDefaultPasswordInputScreen: View {
    // MARK: - Lifecycle

    init(
        email: String,
        submitPassword: @escaping (_ password: String) -> Void,
        loginWithoutPassword: @escaping () -> Void
    ) {
        self.email = email
        self.submitPassword = submitPassword
        self.loginWithoutPassword = loginWithoutPassword
    }

    // MARK: - Internal

    var body: some View {
        VStack {
            Text("Email: \(email)")

            TextField("Password", text: $password)
                .padding()
                .background(Color.gray)
                .cornerRadius(8)

            Button("Submit") {
                submitPassword(password)
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

            Button("Login without password") {
                loginWithoutPassword()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
    }

    // MARK: - Private

    private let email: String
    private let submitPassword: (_ password: String) -> Void
    private let loginWithoutPassword: () -> Void

    @State private var password = ""
}
