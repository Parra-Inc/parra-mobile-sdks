//
//  ParraAuthContent.swift
//  Parra
//
//  Created by Mick MacCallum on 4/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

public struct ParraAuthContent: ContainerContent {
    // MARK: - Lifecycle

    public init(
        icon: ParraImageContent? = ParraAuthContent.appIconImageContent(),
        title: String = Parra.appBundleName() ?? "Welcome",
        subtitle: String? = nil,
        emailPassword: AuthenticationEmailPasswordContent?
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.emailPassword = emailPassword
    }

    // MARK: - Public

    public struct AuthenticationEmailPasswordContent {
        public static let `default` = AuthenticationEmailPasswordContent(
            emailTitle: "Email address",
            emailPlaceholder: nil,
            passwordTitle: "Password",
            passwordPlaceholder: nil,
            loginButtonTitle: "Log in",
            signupButtonTitle: "Don't have an account? Sign up"
        )

        public let emailTitle: String
        public let emailPlaceholder: String?
        public let passwordTitle: String
        public let passwordPlaceholder: String?
        public let loginButtonTitle: String?
        public let signupButtonTitle: String?
    }

    public static let `default` = ParraAuthContent(emailPassword: .default)

    public let icon: ParraImageContent?
    public let title: String
    public let subtitle: String?
    public let emailPassword: AuthenticationEmailPasswordContent?

    public static func appIconImageContent() -> ParraImageContent? {
        guard let appIcon = Parra.appIconFilePath() else {
            return nil
        }

        guard let image = UIImage(contentsOfFile: appIcon.path) else {
            return nil
        }

        return ParraImageContent.image(image, .original)
    }
}
