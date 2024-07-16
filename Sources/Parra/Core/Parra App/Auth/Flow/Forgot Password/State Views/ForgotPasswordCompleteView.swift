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
                text: "Your password has been successfully updated. You can now use your new password to log in.",
                localAttributes: ParraAttributes.Label(
                    text: ParraAttributes.Text(
                        style: .subheadline
                    )
                )
            )
            .layoutPriority(20)

            componentFactory.buildContainedButton(
                config: ParraTextButtonConfig(
                    type: .primary,
                    size: .large,
                    isMaxWidth: true
                ),
                text: "Return to login",
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

    @EnvironmentObject private var componentFactory: ComponentFactory
}

#Preview {
    ParraViewPreview { _ in
        ForgotPasswordCompleteView {}
    }
}
