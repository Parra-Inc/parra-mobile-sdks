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
        params: Params,
        config: Config
    ) {
        self.params = params
        self.config = config
    }

    // MARK: - Public

    public var body: some View {
        VStack(alignment: .leading) {
            primaryContent
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

            if params.inputType == .passkey {
                focusState = .passkeyEmail
            }
        }
        .task {
            // This is for getting the passkey option in the quick type bar
            // when you're logging in without a passkey to get you to use one.
            // If you're on this screen to create a passkey it shouldn't
            // be shown.
            if params.inputType != .passkey {
                do {
                    try await params.attemptPasskeyAutofill?()
                } catch {
                    Logger.error("Failed to attempt passkey autofill", error)
                }
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

    enum Error {
        case invalidEmail
        case invalidPhone
        case networkFailure
    }

    enum Field {
        case passkeyEmail
    }

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
            .focused($focusState, equals: .passkeyEmail)
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
    @State private var errorMessage: String?

    @FocusState private var focusState: Field?

    private let params: Params
    private let config: Config

    @EnvironmentObject private var componentFactory: ComponentFactory
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject private var parraAppInfo: ParraAppInfo
    @Environment(\.parra) private var parra

    @ViewBuilder private var primaryContent: some View {
        defaultTopView

        primaryField

        if let errorMessage {
            componentFactory.buildLabel(
                content: LabelContent(text: errorMessage),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        color: themeObserver.theme.palette.error.toParraColor()
                    ),
                    padding: .md
                )
            )
        }

        componentFactory.buildContainedButton(
            config: ParraTextButtonConfig(
                type: .primary,
                size: .large,
                isMaxWidth: true
            ),
            content: continueButtonContent,
            onPress: submit
        )

        defaultBottomView
    }

    @ViewBuilder private var defaultTopView: some View {
        if let topView = config.topView {
            AnyView(topView)
        } else {
            componentFactory.buildLabel(
                content: LabelContent(text: identityFieldTitle),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .title),
                    padding: .md
                )
            )
        }
    }

    @ViewBuilder private var defaultBottomView: some View {
        Spacer()
    }

    private var identityFieldTitle: String {
        switch params.inputType {
        case .email:
            return "Email"
        case .phone:
            return "Phone number"
        case .emailOrPhone:
            return "Email or phone number"
        case .passkey:
            // With other input types we don't know if the user is logging in
            // or registering. With this one, we do, because they will have been
            // prompted to use existing passkeys by this point.
            return "Register with passkey"
        }
    }

    private func submit() {
        withAnimation {
            errorMessage = nil
            continueButtonContent = continueButtonContent.withLoading(true)
        }

        Task {
            do {
                try await params.submitIdentity(identity)
            } catch {
                withAnimation {
                    errorMessage = error.localizedDescription
                }

                Logger.error("Failed to submit identity", error)
            }

            Task { @MainActor in
                withAnimation {
                    continueButtonContent = continueButtonContent
                        .withLoading(false)
                }
            }
        }
    }
}

#Preview("Email") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityInputScreen(
            params: ParraAuthDefaultIdentityInputScreen.Params(
                inputType: .email,
                submitIdentity: { _ in }
            ),
            config: .default
        )
    }
}

#Preview("Email or Phone") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityInputScreen(
            params: ParraAuthDefaultIdentityInputScreen.Params(
                inputType: .emailOrPhone,
                submitIdentity: { _ in }
            ),
            config: .default
        )
    }
}

#Preview("Phone") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityInputScreen(
            params: ParraAuthDefaultIdentityInputScreen.Params(
                inputType: .phone,
                submitIdentity: { _ in }
            ),
            config: .default
        )
    }
}

#Preview("Passkey") {
    ParraViewPreview { _ in
        ParraAuthDefaultIdentityInputScreen(
            params: ParraAuthDefaultIdentityInputScreen.Params(
                inputType: .passkey,
                submitIdentity: { _ in }
            ),
            config: .default
        )
    }
}
