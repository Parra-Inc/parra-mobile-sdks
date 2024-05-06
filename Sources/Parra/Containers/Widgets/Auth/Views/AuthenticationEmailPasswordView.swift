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
                    validationRules: config.emailValidationRules
                ),
                content: content.emailField,
                localAttributes: TextInputAttributes(
                    padding: .padding(
                        top: 50,
                        bottom: 5
                    ),
                    textContentType: .emailAddress
                )
            )
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.loginTapped()
            }

            componentFactory.buildTextInput(
                config: TextInputConfig(
                    validationRules: config.passwordValidationRules
                ),
                content: content.passwordField,
                localAttributes: TextInputAttributes(
                    padding: .padding(bottom: 16),
                    textContentType: .password
                )
            )
            .submitLabel(.next)
            .focused($focusedField, equals: .password)
            .onSubmit(of: .text) {
                contentObserver.loginTapped()
            }

            componentFactory.buildTextButton(
                variant: .contained,
                config: TextButtonConfig(
                    style: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                content: content.loginButton
            ) {
                contentObserver.loginTapped()
            }

            if let error = contentObserver.error {
                componentFactory.buildLabel(
                    fontStyle: .caption,
                    content: LabelContent(text: error)
                )
                .applyFormCalloutAttributes(erroring: true)
            }

            Spacer()

            componentFactory.buildTextButton(
                variant: .plain,
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
