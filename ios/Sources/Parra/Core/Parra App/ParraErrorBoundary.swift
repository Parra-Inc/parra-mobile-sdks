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
                        tint: parraTheme.palette.warning.toParraColor(),
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
                            color: parraTheme.palette.primaryText.toParraColor(),
                            alignment: .leading
                        )
                    )
                )

                componentFactory.buildLabel(
                    text: errorInfo.userMessage,
                    localAttributes: .init(
                        text: ParraAttributes.Text(
                            style: .body,
                            color: parraTheme.palette.secondaryText.toParraColor(),
                            alignment: .leading
                        )
                    )
                )
            }
            .padding()

            if let retryHandler {
                componentFactory.buildContainedButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .large,
                        isMaxWidth: true
                    ),
                    content: retryButtonContent,
                    onPress: {
                        Task { @MainActor in
                            withAnimation {
                                retryButtonContent = retryButtonContent.withLoading(true)
                            }

                            await retryHandler()

                            withAnimation {
                                retryButtonContent = retryButtonContent.withLoading(false)
                            }
                        }
                    }
                )
            }

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
            using: parraTheme
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
    let retryHandler: (() async -> Void)?

    // MARK: - Private

    @State private var isShowingFeedbackForm = false
    @State private var retryButtonContent = ParraTextButtonContent(
        text: "Try again"
    )

    @Environment(\.parraTheme) private var parraTheme
    @Environment(ParraComponentFactory.self) private var componentFactory
}

#Preview {
    ParraViewPreview { _ in
        ParraErrorBoundary(
            errorInfo: ParraErrorWithUserInfo(
                userMessage: "Failed to perform action necessary to launch the app. Check your connection and try again.",
                underlyingError: ParraError.jsonError("decoding broke")
            ),
            retryHandler: nil
        )
    }
}
