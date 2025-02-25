//
//  ParraContainerRenderer+feedbackForms.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

private let logger = Logger()

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func feedbackFormRenderer(
        config: FeedbackFormWidget.Config,
        parra: Parra,
        data form: ParraFeedbackForm,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> FeedbackFormWidget {
        return parra.parraInternal
            .containerRenderer
            .renderContainer<FeedbackFormWidget>(
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
                    }
                },
                navigationPath: navigationPath
            )
    }
}
