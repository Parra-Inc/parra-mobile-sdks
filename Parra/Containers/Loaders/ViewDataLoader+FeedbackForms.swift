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
        localBuilder: FeedbackFormWidget.BuilderConfig,
        submissionType: FeedbackFormSubmissionType
    ) -> ViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget> {
        return ViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget>(
            loader: { parra, formId in
                return try await parra.parraInternal.feedback.fetchFeedbackForm(
                    formId: formId
                )
            },
            renderer: { parra, form, dismisser in
                let container: FeedbackFormWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        with: localBuilder,
                        params: .init(
                            formData: form.data
                        ),
                        config: config
                    ) { contentObserver in
                        contentObserver.submissionHandler = { data in
                            logger.info("Submitting feedback form data")

                            parra.logEvent(.submit(form: "feedback_form"), [
                                "formId": form.id
                            ])

                            dismisser?(.completed)

                            Task {
                                switch submissionType {
                                case .default:
                                    do {
                                        try await parra.parraInternal
                                            .networkManager
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
                    }

                return container
            }
        )
    }
}
