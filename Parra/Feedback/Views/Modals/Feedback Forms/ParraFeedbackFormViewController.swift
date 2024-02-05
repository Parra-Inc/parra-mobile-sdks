//
//  ParraFeedbackFormViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

import UIKit
import SwiftUI

fileprivate let logger = Logger(category: "Feedback form")

internal class ParraFeedbackFormViewController: UIViewController, ParraModal {
    private let form: ParraFeedbackFormResponse

    required init(
        form: ParraFeedbackFormResponse,
        theme: ParraTheme,
        notificationCenter: NotificationCenterType,
        configuration: ParraFeedbackFormWidgetConfig?
    ) {
        self.form = form

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        modalTransitionStyle = .coverVertical

        let formView = ParraFeedbackFormView(
            state: FeedbackFormViewState(
                formData: form.data,
                submissionHandler: self.onSubmit
            ),
            configObserver: .init(
                configuration: configuration ?? .default
            ),
            themeObserver: .init(
                theme: theme,
                notificationCenter: notificationCenter
            )
        )

        let formViewController = UIHostingController(
            rootView: formView
        )

        formViewController.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(formViewController)
        view.addSubview(formViewController.view)

        NSLayoutConstraint.activate([
            formViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            formViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        formViewController.didMove(toParent: self)

        Parra.logEvent(.view(element: "feedback_form"), [
            "formId": form.id
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

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
                try await Parra.getExistingInstance().networkManager.submitFeedbackForm(
                    with: form.id,
                    data: data
                )
            } catch let error {
                logger.error("Error submitting feedback form: \(form.id)", error)
            }
        }
    }
}