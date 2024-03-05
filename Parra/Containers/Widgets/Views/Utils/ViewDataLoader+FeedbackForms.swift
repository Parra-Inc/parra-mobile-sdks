//
//  ViewDataLoader+FeedbackForms.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension ViewDataLoader {
    static func feedbackFormLoader(
        config: FeedbackFormWidgetConfig,
        localFactory: FeedbackFormWidget.Factory?,
        submissionType: FeedbackFormSubmissionType
    ) -> ViewDataLoader<ParraFeedbackForm, FeedbackFormWidget> {
        return ViewDataLoader<ParraFeedbackForm, FeedbackFormWidget>(
            loader: { parra, type in
                switch type {
                case .id(let formId):
                    return try await parra.feedback.fetchFeedbackForm(
                        formId: formId
                    )
                case .data(let form):
                    return form
                }
            },
            renderer: { parra, form, dismisser in
                let theme = parra.configuration.theme
                let globalComponentAttributes = parra
                    .configuration
                    .globalComponentAttributes

                let componentFactory = ComponentFactory(
                    local: localFactory,
                    global: globalComponentAttributes,
                    theme: theme
                )

                let contentObserver = FeedbackFormWidget.ContentObserver(
                    formData: form.data
                )

                _ = contentObserver.submissionHandler = { data in
                    logger.info("Submitting feedback form data")

                    parra.logEvent(.submit(form: "feedback_form"), [
                        "formId": form.id
                    ])

                    dismisser?(.completed)

                    Task {
                        switch submissionType {
                        case .default:
                            do {
                                try await parra.networkManager
                                    .submitFeedbackForm(
                                        with: form.id,
                                        data: data
                                    )
                            } catch {
                                logger.error(
                                    "Error submitting feedback form: \(form.id)",
                                    error
                                )
                            }
                        case .custom(let handler):
                            await handler(data)
                        }
                    }
                }

                let style = FeedbackFormWidget.Style.default(
                    with: theme
                )

                FeedbackFormWidget(
                    componentFactory: componentFactory,
                    contentObserver: contentObserver,
                    config: config,
                    style: style
                )
            }
        )
    }
}
