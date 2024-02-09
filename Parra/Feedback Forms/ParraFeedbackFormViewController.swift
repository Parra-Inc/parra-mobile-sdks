//
//  ParraFeedbackFormViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

import SwiftUI
import UIKit

private let logger = Logger(category: "Feedback form")

class ParraFeedbackFormViewController: UIViewController, ParraModal {
    // MARK: - Lifecycle

    required init(
        form: ParraFeedbackFormResponse,
        theme: ParraTheme,
        globalComponentAttributes: GlobalComponentAttributes,
        notificationCenter: NotificationCenterType,
        localFactory: FeedbackFormWidgetComponentFactory?
    ) {
        self.form = form

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        modalTransitionStyle = .coverVertical

        let componentFactory = ComponentFactory(
            local: localFactory,
            global: globalComponentAttributes,
            theme: theme
        )

        let contentObserver = FeedbackFormContentObserver(
            formData: form.data
        )
        contentObserver.submissionHandler = onSubmit

        let formView = FeedbackFormWidget(
            componentFactory: componentFactory,
            config: .default,
            contentObserver: contentObserver,
            themeObserver: ParraThemeObserver(
                theme: theme,
                notificationCenter: notificationCenter
            )
        )

        let formViewController = UIHostingController(
            rootView: formView
        )

        formViewController.view
            .translatesAutoresizingMaskIntoConstraints = false
        addChild(formViewController)
        view.addSubview(formViewController.view)

        NSLayoutConstraint.activate([
            formViewController.view.leadingAnchor
                .constraint(equalTo: view.leadingAnchor),
            formViewController.view.trailingAnchor
                .constraint(equalTo: view.trailingAnchor),
            formViewController.view.topAnchor
                .constraint(equalTo: view.topAnchor),
            formViewController.view.bottomAnchor
                .constraint(equalTo: view.bottomAnchor)
        ])

        formViewController.didMove(toParent: self)

        Parra.logEvent(.view(element: "feedback_form"), [
            "formId": form.id
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Internal

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Private

    private let form: ParraFeedbackFormResponse

    private func onSubmit(
        data: [FeedbackFormField: String]
    ) {
        logger.info("Submitting feedback form data")

        Parra.logEvent(.submit(form: "feedback_form"), [
            "formId": form.id
        ])

        dismiss(animated: true)

        Task {
            do {
                try await Parra.getExistingInstance().networkManager
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
    }
}
