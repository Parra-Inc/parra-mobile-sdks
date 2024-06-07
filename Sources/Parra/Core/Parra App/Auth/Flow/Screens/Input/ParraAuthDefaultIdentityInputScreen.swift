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
            inputType: ParraIdentityInputType,
            submit: @escaping (_ identity: String) async throws -> Void
        ) {
            self.inputType = inputType
            self.submit = submit
        }

        // MARK: - Public

        public let inputType: ParraIdentityInputType
        public let submit: (_ identity: String) async throws -> Void
    }

    public var body: some View {
        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                content: LabelContent(text: identityFieldTitle),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .title),
                    padding: .md
                )
            )

            primaryField

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
            // This is for getting the passkey option in the quick type bar
            // when you're logging in without a passkey to get you to use one.
            // If you're on this screen to create a passkey it shouldn't
            // be shown.
            if params.inputType != .passkey {
                await flowManager.triggerPasskeyLoginRequest(
                    username: nil,
                    presentationMode: .autofill,
                    using: parraAppInfo,
                    authService: parra.parraInternal.authService
                )
            }
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

    // MARK: - Internal

    @ViewBuilder var primaryField: some View {
        if params.inputType == .passkey {
            componentFactory.buildTextInput(
                config: TextInputConfig(
                    validationRules: [.email],
                    keyboardType: .emailAddress,
                    textContentType: .username,
                    textInputAutocapitalization: .never
                ),
                content: TextInputContent(
                    placeholder: "Email address",
                    textChanged: { newValue in
                        identity = newValue ?? ""
                    }
                )
            )
            .onSubmit(of: .text) {
                submit()
            }
        } else {
            let inputMode: PhoneOrEmailTextInputView.Mode = switch params
                .inputType
            {
            case .emailOrPhone:
                .auto
            case .email:
                .email
            case .phone:
                .phone
            default:
                .auto
            }

            PhoneOrEmailTextInputView(
                entry: $identity,
                mode: inputMode,
                currendMode: $emailPhoneFieldCurrentMode,
                onSubmit: submit
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

    private var identityFieldTitle: String {
        switch params.inputType {
        case .email:
            return "Email"
        case .phone:
            return "Phone number"
        case .emailOrPhone:
            return "Email or phone number"
        case .passkey:
            return "Passkey"
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
