//
//  ParraAuthDefaultIdentityInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
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
            availableAuthMethods: [ParraAuthenticationMethod],
            submit: @escaping (_ identity: String) async throws -> Void
        ) {
            self.availableAuthMethods = availableAuthMethods
            self.submit = submit
        }

        // MARK: - Public

        public let availableAuthMethods: [ParraAuthenticationMethod]
        public let submit: (_ identity: String) async throws -> Void
    }

    public var body: some View {
        let allowsPhone = availablePasswordlessMethods.contains(.sms)
        let allowsEmail = params.availableAuthMethods.contains(.password)
            || availablePasswordlessMethods.contains(.email)

        let inputMode: PhoneOrEmailTextInputView.Mode = if allowsEmail,
                                                           allowsPhone
        {
            .auto
        } else if allowsEmail {
            .email
        } else if allowsPhone {
            .phone
        } else {
            .auto
        }

        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                content: LabelContent(text: identityFieldTitle),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .title),
                    padding: .md
                )
            )

            PhoneOrEmailTextInputView(
                entry: $identity,
                mode: inputMode,
                currendMode: $emailPhoneFieldCurrentMode,
                onSubmit: submit
            )

            SecureField(
                text: $identity,
                label: {
                    Text("Password")
                }
            )
            .textContentType(.password)

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: continueButtonContent,
                onPress: submit
            )

            Spacer()
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .applyDefaultWidgetAttributes(
            using: themeObserver.theme
        )
        .onAppear {
            continueButtonContent = TextButtonContent(
                text: continueButtonContent.text,
                isDisabled: identity.isEmpty
            )
        }
        .task {
            await flowManager.triggerPasskey(
                username: nil,
                presentationMode: .autofill,
                using: parraAppInfo,
                authService: parra.parraInternal.authService
            )
        }
        .onChange(of: identity) { _, newValue in
            let trimmed = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            continueButtonContent = TextButtonContent(
                text: continueButtonContent.text,
                isDisabled: trimmed.isEmpty
            )
        }
    }

    // MARK: - Private

    @State private var identity = ""
    @State private var continueButtonContent: TextButtonContent = .init(
        text: "Continue",
        isDisabled: true
    )
    @State private var emailPhoneFieldCurrentMode: PhoneOrEmailTextInputView
        .Mode = .auto

    private let params: Params

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @EnvironmentObject private var flowManager: AuthenticationFlowManager
    @Environment(\.parra) private var parra

    private var availablePasswordlessMethods: [
        ParraAuthenticationMethod
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
