//
//  ParraAuthContent.swift
//  Parra
//
//  Created by Mick MacCallum on 4/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraAuthContent: ContainerContent {
    // MARK: - Lifecycle

    public init(
        title: String = Parra.appBundleName() ?? "Welcome",
        subtitle: String? = nil,
        emailPassword: AuthenticationEmailPasswordContent?
    ) {
        self.title = title
        self.subtitle = subtitle
        self.emailPassword = emailPassword
    }

    // MARK: - Public

    public struct AuthenticationEmailPasswordContent {
        public static let `default` = AuthenticationEmailPasswordContent(
            emailPlaceholder: "Email address",
            passwordPlaceholder: "Password",
            loginButtonTitle: "Log in",
            signupButtonTitle: "Don't have an account? Sign up"
        )

        public let emailPlaceholder: String?
        public let passwordPlaceholder: String?
        public let loginButtonTitle: String?
        public let signupButtonTitle: String?
    }

    public static let `default` = ParraAuthContent(emailPassword: .default)

    public let title: String
    public let subtitle: String?
    public let emailPassword: AuthenticationEmailPasswordContent?
}
