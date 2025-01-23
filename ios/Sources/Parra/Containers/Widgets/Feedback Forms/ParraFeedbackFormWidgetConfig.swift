//
//  ParraFeedbackFormWidgetConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public class ParraFeedbackFormWidgetConfig: ParraContainerConfig {
    // MARK: - Lifecycle

    public init(
        maxTextFieldCharacters: Int = ParraFeedbackFormWidgetConfig.default
            .maxTextFieldCharacters,
        defaultValues: [String: String] = ParraFeedbackFormWidgetConfig.default
            .defaultValues,
        contextMessage: String? = ParraFeedbackFormWidgetConfig.default.contextMessage,
        successToastContent: ParraAlertContent? = ParraFeedbackFormWidgetConfig.default
            .successToastContent
    ) {
        self.maxTextFieldCharacters = maxTextFieldCharacters
        self.defaultValues = defaultValues
        self.contextMessage = contextMessage
        self.successToastContent = successToastContent
    }

    // MARK: - Public

    public static let `default` = ParraFeedbackFormWidgetConfig(
        maxTextFieldCharacters: 30,
        defaultValues: [:],
        contextMessage: nil,
        successToastContent: ParraAlertContent(
            title: ParraLabelContent(text: "Feedback Sent"),
            subtitle: ParraLabelContent(
                text: "Your feedback has been recorded successfully."
            ),
            icon: ParraAlertContent.defaultIcon(for: .success),
            dismiss: ParraAlertContent.defaultDismiss(for: .success)
        )
    )

    /// The maximum number of characters allowed in a text field input.
    public let maxTextFieldCharacters: Int

    /// The default values that will be added to each field in the form, keyed
    /// by the "name" for the field in the Parra dashboard.
    public let defaultValues: [String: String]

    public let contextMessage: String?

    /// What should be displayed in the toast shown when the feedback form is
    /// submitted. If this is set to `nil`, no toast will be shown.
    public let successToastContent: ParraAlertContent?
}
