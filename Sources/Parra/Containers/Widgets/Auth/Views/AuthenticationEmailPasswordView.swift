//
//  AuthenticationEmailPasswordView.swift
//  Parra
//
//  Created by Mick MacCallum on 4/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AuthenticationEmailPasswordView: View {
    enum Field: Int, Hashable, CaseIterable {
        case email
        case password
    }

    @FocusState private var focusedField: Field?
    @Environment(\.parra) var parra
    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var navigationState: NavigationState

    let config: ParraAuthConfig
    let content: AuthenticationWidget.ContentObserver.EmailContent
    let contentObserver: AuthenticationWidget.ContentObserver
    let componentFactory: ComponentFactory

    var body: some View {
        VStack(spacing: 0) {
//            componentFactory.buildTextInput(
//                config: TextInputConfig(
//                    validationRules: config.emailValidationRules,
//                    textContentType: .emailAddress,
//                    textInputAutocapitalization: .never,
//                    autocorrectionDisabled: true
//                ),
//                content: content.emailField,
//                localAttributes: ParraAttributes.TextInput(
//                    padding: .custom(
//                        .padding(top: 50, bottom: 5)
//                    )
//                )
//            )
//            .submitLabel(.next)
//            .focused($focusedField, equals: .password)
//            .onSubmit(of: .text) {
//                contentObserver.loginTapped()
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
//                contentObserver.loginTapped()
//            }

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: content.loginButton
            ) {
                focusedField = nil

                contentObserver.loginTapped()
            }

            componentFactory.buildPlainButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .small,
                    isMaxWidth: false
                ),
                content: content.forgotPasswordButton
            ) {}

            if let error = contentObserver.error {
                componentFactory.buildLabel(
                    content: LabelContent(text: error),
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .caption,
                            color: themeObserver.theme.palette.error
                                .toParraColor().opacity(0.8)
                        )
                    )
                )
            }

            Spacer()

            componentFactory.buildPlainButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .small,
                    isMaxWidth: false
                ),
                content: content.signupButton
            ) {
                focusedField = nil

                navigationState.navigationPath.append("signup")
            }
        }
        .onAppear {
            // When the view appears/reappears trigger a re-validation so that
            // any changes in field values are reflected in the UI.
            contentObserver.validateEmailFields()
        }
    }
}
