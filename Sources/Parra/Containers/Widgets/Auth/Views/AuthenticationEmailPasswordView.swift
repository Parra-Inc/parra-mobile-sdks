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
                config: config.emailField,
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
                config: config.passwordField,
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
                config: config.loginButton,
                content: content.loginButton
            ) {
                contentObserver.loginTapped()
            }

            if let error = contentObserver.error {
                componentFactory.buildLabel(
                    config: config.loginErrorLabel,
                    content: LabelContent(text: error),
                    localAttributes: .defaultFormCallout(
                        in: themeObserver.theme,
                        with: config.loginErrorLabel,
                        erroring: true
                    ).withUpdates(
                        updates: LabelAttributes(
                            padding: .padding(top: 4)
                        )
                    )
                )
            }

            Spacer()

            componentFactory.buildTextButton(
                variant: .plain,
                config: config.signupButton,
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
