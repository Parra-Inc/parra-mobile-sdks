//
//  ParraFeedbackFormViewController.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 6/5/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

import UIKit
import ParraCore
import SwiftUI

internal class ParraFeedbackFormViewController: UIViewController, ParraModal {
    private let form: ParraFeedbackFormResponse

    required init(form: ParraFeedbackFormResponse,
                  config: ParraCardViewConfig) {
        self.form = form

        super.init(nibName: nil, bundle: nil)

        modalPresentationStyle = .pageSheet
        modalTransitionStyle = .coverVertical

        let formViewController = UIHostingController(
            rootView: ParraFeedbackFormView(
                formId: form.id,
                data: form.data,
                config: config,
                onSubmit: onSubmit
            )
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

        Parra.logAnalyticsEvent(ParraSessionEventType.impression(
            location: "form",
            module: ParraFeedback.self
        ), params: [
            "formId": form.id
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func onSubmit(data: [FeedbackFormField: String]) {
        parraLogInfo("Submitting feedback form data")

        Parra.logAnalyticsEvent(ParraSessionEventType.action(
            source: "form-submit",
            module: ParraFeedback.self
        ), params: [
            "formId": form.id
        ])

        dismiss(animated: true)

        Task {
            do {
                try await Parra.API.submitFeedbackForm(with: form.id, data: data)
            } catch let error {
                parraLogError("Error submitting feedback form: \(form.id)", error)
            }
        }
    }
}
