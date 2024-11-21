//
//  LaunchShortcutManager.swift
//  Parra
//
//  Created by Mick MacCallum on 11/21/24.
//

import SwiftUI

private let logger = Logger()

final class LaunchShortcutManager {
    // MARK: - Lifecycle

    init(
        options: ParraLaunchShortcutOptions,
        modalScreenManager: ModalScreenManager,
        api: API,
        feedback: ParraFeedback
    ) {
        self.options = options
        self.modalScreenManager = modalScreenManager
        self.feedback = feedback
        self.api = api
    }

    // MARK: - Internal

    @MainActor
    func handleLaunchShortcut(_ shortcut: UIApplicationShortcutItem) -> Bool {
        Parra.logEvent(.tap(element: "launch_shortcut"), [
            "type": shortcut.type,
            "title": shortcut.localizedTitle
        ])

        guard options.enabled else {
            logger.debug("Launch shortcuts disabled. Skipping handler.")
            return false
        }

        if shortcut.type == LaunchShortcutManager.Constants.feedbackShortcutId {
            if let appInfo = Parra.default.parraInternal.appState.appInfo,
               let formId = options.feedbackFormId ?? appInfo.application
               .defaultFeedbackFormId
            {
                Task { @MainActor in
                    await fetchAndPresentFeedbackForm(
                        formId: formId
                    )
                }

                return true
            } else {
                logger.debug(
                    "Missing feedback form id", [
                        "type": shortcut.type
                    ]
                )
            }
        } else {
            logger.debug(
                "Launch shortcut not recognized. Skipping handler.", [
                    "type": shortcut.type
                ]
            )
        }

        return false
    }

    // MARK: - Private

    private let options: ParraLaunchShortcutOptions
    private let modalScreenManager: ModalScreenManager
    private let feedback: ParraFeedback
    private let api: API

    @MainActor
    private func fetchAndPresentFeedbackForm(
        formId: String
    ) async {
        do {
            let formData = try await feedback.fetchFeedbackForm(
                formId: formId
            )

            let contentObserver = FeedbackFormWidget.ContentObserver(
                initialParams: FeedbackFormWidget.ContentObserver.InitialParams(
                    formData: formData.data
                )
            )

            contentObserver.submissionHandler = { data in
                logger.info("Submitting feedback form data")

                Parra.logEvent(.submit(form: "feedback_form"), [
                    "formId": formId
                ])

                do {
                    try await self.api.submitFeedbackForm(
                        with: formId,
                        data: data
                    )
                } catch {
                    logger.error(
                        "Error submitting feedback form: \(formId)",
                        error
                    )
                }

                self.modalScreenManager.dismissModalView()
            }

            modalScreenManager.presentModalView(
                of: FeedbackFormWidget.self,
                with: .default,
                contentObserver: contentObserver,
                showsDismissalButton: true
            )
        } catch {
            logger.error("Error fetching feedback form", error)
        }
    }
}

// MARK: LaunchShortcutManager.Constants

extension LaunchShortcutManager {
    enum Constants {
        static let feedbackShortcutId = "parra-launch-shortcut-feedback"
    }
}
