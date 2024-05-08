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
            componentFactory.buildTextInput(
                config: TextInputConfig(
                    validationRules: config.emailValidationRules,
                    textContentType: .emailAddress,
                    textInputAutocapitalization: .never,
                    autocorrectionDisabled: true
                ),
                content: content.emailField
            )
            .padding(.top, 50)
            .padding(.bottom, 5)
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.loginTapped()
            }

            componentFactory.buildTextInput(
                config: TextInputConfig(
                    validationRules: config.passwordValidationRules,
                    isSecure: true,
                    textContentType: .password,
                    textInputAutocapitalization: .never,
                    autocorrectionDisabled: true
                ),
                content: content.passwordField
            )
            .padding(.bottom, 16)
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.loginTapped()
            }

            componentFactory.buildContainedButton(
                config: TextButtonConfig(
                    style: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: content.loginButton
            ) {
                contentObserver.loginTapped()
            }

            componentFactory.buildPlainButton(
                config: TextButtonConfig(
                    style: .primary,
                    size: .small,
                    isMaxWidth: false
                ),
                content: content.forgotPasswordButton
            ) {}

            if let error = contentObserver.error {
                componentFactory.buildLabel(
                    fontStyle: .caption,
                    content: LabelContent(text: error)
                )
                .applyFormCalloutAttributes(erroring: true)
            }

            Spacer()

            componentFactory.buildPlainButton(
                config: TextButtonConfig(
                    style: .primary,
                    size: .small,
                    isMaxWidth: false
                ),
                content: content.signupButton
            ) {
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
