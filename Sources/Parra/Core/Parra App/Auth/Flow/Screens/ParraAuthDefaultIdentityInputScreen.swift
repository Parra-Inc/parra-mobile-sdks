//
//  ParraAuthDefaultIdentityInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAuthDefaultIdentityInputScreen: ParraAuthScreen {
    // MARK: - Lifecycle

    public init(
        params: Params
    ) {
        self.params = params
    }

    // MARK: - Public

    public struct Params: ParraAuthScreenParams {
        // MARK: - Lifecycle

        public init(
            // basically whether to show "email" "phone number" or "email or phone number" in the placeholder
            availableAuthMethods: [AuthenticationMethod],
            submit: @escaping (_ identity: String) async throws -> Void
        ) {
            self.availableAuthMethods = availableAuthMethods
            self.submit = submit
        }

        // MARK: - Public

        public let availableAuthMethods: [AuthenticationMethod]
        public let submit: (_ identity: String) async throws -> Void
    }

    public var body: some View {
        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                content: LabelContent(text: identityFieldTitle),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .largeTitle),
                    padding: .md
                )
            )

            componentFactory.buildTextInput(
                config: identityFieldConfig,
                content: TextInputContent(
                    placeholder: identityFieldTitle,
                    errorMessage: .init()
                ) { newText in
                    onIdentityChanged(newText ?? "")
                },
                localAttributes: ParraAttributes.TextInput(
                    padding: .md
                )
            )
            .onSubmit(of: .text, submit)

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: continueButtonContent,
                onPress: submit
            )
        }
        .frame(maxWidth: .infinity)
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
        .onAppear {
            continueButtonContent = continueButtonContent.withLoading(false)
        }
    }

    // MARK: - Private

    @State private var identity = ""
    @State private var continueButtonContent: TextButtonContent = .init(
        text: "Continue"
    )

    private let params: Params

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo

    private var availablePasswordlessMethods: [
        AuthenticationMethod
            .PasswordlessType
    ] {
        params.availableAuthMethods.filter { method in
            switch method {
            case .passwordless:
                return true
            default:
                return false
            }
        }.compactMap { method in
            switch method {
            case .passwordless(let passwordlessType):
                return passwordlessType
            default:
                return nil
            }
        }
    }

    private var identityFieldConfig: TextInputConfig {
        let availableAuthMethods = params.availableAuthMethods

        let emailConfig = TextInputConfig(
            validationRules: [.email],
            keyboardType: .emailAddress,
            textContentType: .emailAddress,
            textInputAutocapitalization: .never
        )

        return if availableAuthMethods.contains(where: { method in
            method == .password
        }) {
            emailConfig
        } else if let firstPasswordlessMethod = availablePasswordlessMethods
            .first
        {
            switch firstPasswordlessMethod {
            case .email:
                emailConfig
            case .sms:
                TextInputConfig(
                    validationRules: [.phone],
                    keyboardType: .phonePad,
                    textContentType: .telephoneNumber
                )
            }
        } else {
            emailConfig
        }
    }

    private var identityFieldTitle: String {
        let methods = availablePasswordlessMethods

        if methods.isEmpty {
            return "Email"
        }

        let canUseEmail = params.availableAuthMethods.contains(.password)
            || methods.contains(.email)
        let canUseSms = methods.contains(.sms)

        if canUseEmail, canUseSms {
            return "Email or phone number"
        } else if canUseSms {
            return "Phone number"
        } else {
            return "Email"
        }
    }

    private func onIdentityChanged(
        _ identity: String
    ) {
        self.identity = identity
    }

    private func submit() {
        continueButtonContent = continueButtonContent.withLoading(true)

        Task {
            do {
                try await params.submit(identity)
            } catch {
                print(error)
            }

            Task { @MainActor in
                continueButtonContent = continueButtonContent.withLoading(false)
            }
        }
    }
}
