//
//  ParraAuthDefaultIdentityInputScreen.swift
//  Parra
//
//  Created by Mick MacCallum on 5/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import AuthenticationServices
import SwiftUI

@MainActor
public struct ParraAuthDefaultIdentityInputScreen: ParraAuthScreen, Equatable {
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
        let attributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        ScrollView {
            VStack(alignment: .leading) {
                primaryContent
                    .applyPadding(
                        size: attributes.contentPadding,
                        on: [.horizontal, .bottom],
                        from: parraTheme
                    )
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .navigationBarTitleDisplayMode(.inline)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .applyWidgetAttributes(
            attributes: attributes.withoutContentPadding(),
            using: parraTheme
        )
        .onAppear {
            continueButtonContent = ParraTextButtonContent(
                text: continueButtonContent.text,
                isDisabled: identity.isEmpty
            )
        }
        .task {
            // This is for getting the passkey option in the quick type bar
            // when you're logging in without a passkey to get you to use one.
            // If you're on this screen to create a passkey it shouldn't
            // be shown.
            if !identity.isEmpty {
                return
            }

            if !isFocused {
                Task { @MainActor in
                    isFocused = true
                }
            }

            let shouldAutofill = params.shouldAttemptPasskeyAutofill?() ?? false
            guard shouldAutofill else {
                return
            }

            Task.detached {
                await params.attemptPasskeyAutofill?()
            }
        }
        .onChange(of: identity) { _, newValue in
            let trimmed = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            continueButtonContent = ParraTextButtonContent(
                text: continueButtonContent.text,
                isDisabled: trimmed.isEmpty
            )
        }
    }

    public static func == (
        lhs: ParraAuthDefaultIdentityInputScreen,
        rhs: ParraAuthDefaultIdentityInputScreen
    ) -> Bool {
        return true
    }

    // MARK: - Internal

    enum Error {
        case invalidEmail
        case invalidPhone
        case networkFailure
    }

    @Environment(\.isPresented) var isPresented

    @ViewBuilder
    @MainActor var primaryField: some View {
        let inputMode: PhoneOrEmailTextInputView.Mode = switch params
            .inputType
        {
        case .emailOrPhone:
            .auto
        case .email:
            .email
        case .phone:
            .phone
        }

        PhoneOrEmailTextInputView(
            entry: $identity,
            isFocused: $isFocused,
            mode: inputMode,
            currendMode: $emailPhoneFieldCurrentMode,
            onSubmit: submit
        )
    }

    // MARK: - Private

    @MainActor
    @FocusState private var isFocused: Bool
    @State private var identity = ""
    @State private var continueButtonContent: ParraTextButtonContent = .init(
        text: "Continue",
        isDisabled: true
    )
    @State private var emailPhoneFieldCurrentMode: PhoneOrEmailTextInputView
        .Mode = .auto
    @State private var errorMessage: String?

    private let params: Params
    private let config: Config

    @Environment(ComponentFactory.self) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme

    @ViewBuilder private var primaryContent: some View {
        defaultTopView

        primaryField

        if let errorMessage {
            componentFactory.buildLabel(
                content: ParraLabelContent(text: errorMessage),
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        color: parraTheme.palette.error.toParraColor()
                    ),
                    padding: .lg
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
                content: ParraLabelContent(text: identityFieldTitle),
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .title),
                    padding: .md
                )
            )
        }
    }

    private var defaultBottomView: some View {
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

                withAnimation {
                    errorMessage = nil
                }
            } catch let error as ParraError {
                withAnimation {
                    errorMessage = error.userMessage
                }

                Logger.error("Failed to submit identity", error)
            } catch {
                withAnimation {
                    errorMessage = error.localizedDescription
                }

                Logger.error("Failed to submit identity. Unknown error", error)
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
