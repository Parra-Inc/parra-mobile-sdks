//
//  ForgotPasswordCompleteView.swift
//  Parra
//
//  Created by Mick MacCallum on 7/16/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ForgotPasswordCompleteView: View {
    // MARK: - Lifecycle

    init(onComplete: @escaping () -> Void) {
        self.onComplete = onComplete
    }

    // MARK: - Internal

    let onComplete: () -> Void

    var body: some View {
        // reset password in account settings vs. during the login flow.
        let (subtitle, doneButtonTitle) = switch parraAuthState {
        case .authenticated, .anonymous:
            (
                "Your password has been successfully updated.",
                "Dismiss"
            )
        case .undetermined, .guest:
            (
                "Your password has been successfully updated. You can now use your new password to log in.",
                "Return to login"
            )
        }

        VStack(alignment: .leading, spacing: 12) {
            componentFactory.buildLabel(
                text: "Password updated",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .title
                    ),
                    padding: ParraPaddingSize.custom(
                        .padding(top: 6, bottom: 12)
                    )
                )
            )
            .layoutPriority(20)

            componentFactory.buildLabel(
                text: subtitle,
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .subheadline
                    )
                )
            )
            .layoutPriority(20)

            Spacer()

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                text: doneButtonTitle,
                localAttributes: ParraAttributes.ContainedButton(
                    normal: ParraAttributes.ContainedButton.StatefulAttributes(
                        padding: .zero
                    )
                ),
                onPress: {
                    onComplete()
                }
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAuthState) private var parraAuthState
}

#Preview {
    ParraViewPreview { _ in
        ForgotPasswordCompleteView {}
    }
}
