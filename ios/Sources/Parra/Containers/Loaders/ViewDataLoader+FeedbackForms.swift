//
//  ViewDataLoader+FeedbackForms.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension ParraViewDataLoader {
    static func feedbackFormLoader(
        config: ParraFeedbackFormWidgetConfig,
        submissionType: FeedbackFormSubmissionType
    ) -> ParraViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget> {
        return ParraViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget>(
            renderer: { parra, form, navigationPath, dismisser in
                let container: FeedbackFormWidget = parra.parraInternal
                    .containerRenderer
                    .renderContainer(
                        params: .init(
                            config: config,
                            formData: form.data
                        ),
                        config: config,
                        contentTransformer: { contentObserver in
                            contentObserver.submissionHandler = { data in
                                logger.info("Submitting feedback form data")

                                parra.logEvent(.submit(form: "feedback_form"), [
                                    "formId": form.id
                                ])

                                dismisser?(.completed)

                                switch submissionType {
                                case .default:
                                    do {
                                        try await parra.parraInternal
                                            .api
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
                        },
                        navigationPath: navigationPath
                    )

                return container
            }
        )
    }
}
