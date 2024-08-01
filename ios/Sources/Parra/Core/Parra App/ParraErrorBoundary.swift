//
//  ParraErrorBoundary.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger(category: "Parra Error Boundary")

public struct ParraErrorBoundary: View {
    // MARK: - Public

    public var body: some View {
        VStack(alignment: .center, spacing: 12) {
            VStack {
                componentFactory.buildImage(
                    content: .symbol("exclamationmark.triangle.fill"),
                    localAttributes: ParraAttributes.Image(
                        tint: themeManager.theme.palette.warning.toParraColor(),
                        opacity: 0.76,
                        size: CGSize(width: 100, height: 100),
                        padding: .lg
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .center)

            VStack(alignment: .center, spacing: 8) {
                componentFactory.buildLabel(
                    text: "Oops!",
                    localAttributes: .init(
                        text: ParraAttributes.Text(
                            style: .largeTitle,
                            color: themeManager.theme.palette.primaryText.toParraColor(),
                            alignment: .leading
                        )
                    )
                )

                componentFactory.buildLabel(
                    text: errorInfo.userMessage,
                    localAttributes: .init(
                        text: ParraAttributes.Text(
                            style: .body,
                            color: themeManager.theme.palette.secondaryText.toParraColor(),
                            alignment: .leading
                        )
                    )
                )
            }
            .padding()

            // TODO: Come back to this when we can support form submission:
            // a) without a pre-defined ID in the dashboard.
            // b) when we can submit forms without auth
            //
//            componentFactory.buildContainedButton(
//                config: ParraTextButtonConfig(
//                    type: .primary,
//                    size: .large,
//                    isMaxWidth: true
//                ),
//                text: "Report this issue",
//                onPress: {
//                    isShowingFeedbackForm = true
//                }
//            )
        }
        .applyDefaultWidgetAttributes(
            using: themeManager.theme
        )
        .onAppear {
            logger.error(
                "Displaying error boundary",
                errorInfo.underlyingError,
                [
                    "message": errorInfo.userMessage
                ]
            )
        }
        .presentParraFeedbackForm(
            by: "error-boundary-form",
            isPresented: $isShowingFeedbackForm
        )
    }

    // MARK: - Internal

    struct ErrorInfo {
        let userMessage: String
        let error: LocalizedError
    }

    let errorInfo: ParraErrorWithUserInfo

    // MARK: - Private

    @State private var isShowingFeedbackForm = false

    @EnvironmentObject private var themeManager: ParraThemeManager
    @EnvironmentObject private var componentFactory: ComponentFactory
}

#Preview {
    ParraViewPreview { _ in
        ParraErrorBoundary(
            errorInfo: ParraErrorWithUserInfo(
                userMessage: "Failed to perform action necessary to launch the app. Check your connection and try again.",
                underlyingError: ParraError.jsonError("decoding broke")
            )
        )
    }
}
