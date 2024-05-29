//
//  SignupWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 4/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO:
// 1. Forgot password?
// 2. Terms of Service

/// The login screen for the Parra app.
struct SignupWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ParraAuthConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Public

    public var body: some View {
        signupContent
            .applyDefaultWidgetAttributes(
                using: themeObserver.theme
            )
    }

    // MARK: - Internal

    enum Field: Int, Hashable, CaseIterable {
        case email
        case password
    }

    let componentFactory: ComponentFactory
    let config: ParraAuthConfig

    @StateObject var contentObserver: AuthenticationWidget.ContentObserver

    @ViewBuilder var signupContent: some View {
        let content = contentObserver.content.signupContent

        VStack(spacing: 0) {
            Spacer()

//            componentFactory.buildTextInput(
//                config: TextInputConfig(
//                    validationRules: config.emailValidationRules,
//                    textContentType: .emailAddress,
//                    textInputAutocapitalization: .never,
//                    autocorrectionDisabled: true
//                ),
//                content: content.emailField
//            )
//            .submitLabel(.next)
//            .focused($focusedField, equals: .email)
//            .onSubmit {
//                focusNextField($focusedField)
//            }

//            componentFactory.buildTextInput(
//                config: TextInputConfig(
//                    validationRules: config.passwordValidationRules,
//                    isSecure: true,
//                    textContentType: .password,
//                    textInputAutocapitalization: .never,
//                    autocorrectionDisabled: true
//                ),
//                content: content.passwordField,
//                localAttributes: ParraAttributes.TextInput(
//                    padding: .custom(
//                        .padding(bottom: 16)
//                    )
//                )
//            )
//            .submitLabel(.next)
//            .focused($focusedField, equals: .password)
//            .onSubmit(of: .text) {
//                focusedField = nil
//
//                contentObserver.signupTapped()
//            }

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: content.signupButton
            ) {
                focusedField = nil

                contentObserver.signupTapped()
            }
        }
        .padding(.top, 60)

        Spacer()

        legal
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver

    @FocusState private var focusedField: Field?
    @Environment(\.parra) private var parra

    @ViewBuilder private var legal: some View {
        HStack {
            if let privacyPolicy = contentObserver.legalInfo.privacyPolicy {
                buttonForLegalDocument(privacyPolicy)
            }

            //            componentFactory.buildLabel(
            //                fontStyle: .body,
            //                content: LabelContent(text: "·")
            //            )
        }
    }

    @ViewBuilder
    private func buttonForLegalDocument(
        _ document: LegalDocument
    ) -> some View {
        componentFactory.buildPlainButton(
            config: ParraTextButtonConfig(
                type: .secondary,
                size: .small
            ),
            content: TextButtonContent(
                text: LabelContent(
                    text: document.title
                )
            )
        ) {
            parra.parraInternal.openLink(
                url: document.url
            )
        }
    }
}

#Preview {
    ParraContainerPreview<SignupWidget> { parra, factory, config in
        SignupWidget(
            config: config,
            componentFactory: factory,
            contentObserver: .init(
                initialParams: .init(
                    config: .default,
                    content: .default,
                    authService: parra.parraInternal.authService,
                    alertManager: parra.parraInternal.alertManager,
                    legalInfo: AppInfo.validStates()[0].legal
                )
            )
        )
    }
}
