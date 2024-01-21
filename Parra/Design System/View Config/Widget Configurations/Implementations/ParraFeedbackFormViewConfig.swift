//
//  ParraFeedbackFormViewConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

public struct ParraFeedbackFormWidgetConfig: ParraWidgetConfigurationType {
    let title: ParraLabelViewConfig?
    let description: ParraLabelViewConfig?

    /// Any dynamic "select" fields
    let selectFields: ParraSelectViewConfig?

    /// Any dynamic "text" fields
    let textFields: ParraTextInputViewConfig?

    let submitButton: ParraButtonViewConfig?

    // Powered by Parra button is not user configurable.

    static let `default` = ParraFeedbackFormWidgetConfig(
        title: .init(
            font: .largeTitle.bold(),
            color: .black,
            background: nil,
            cornerRadius: nil,
            padding: nil
        ),
        description: .init(
            font: .subheadline,
            color: .gray,
            background: nil,
            cornerRadius: nil,
            padding: nil
        ),
        selectFields: nil,
        textFields: nil,
        submitButton: .init(
            title: .init(
                font: .headline,
                color: .white,
                background: nil,
                cornerRadius: nil,
                padding: nil
            ),
            titlePressed: nil,
            titleDisabled: nil,
            background: nil,
            cornerRadius: .init(allCorners: 8),
            padding: nil
        )
    )

    func withDefaultsApplied() -> ParraFeedbackFormWidgetConfig {
        return ParraFeedbackFormWidgetConfig(
            title: title ?? Self.default.title,
            description: description ?? Self.default.description,
            selectFields: selectFields ?? Self.default.selectFields,
            textFields: textFields ?? Self.default.textFields,
            submitButton: submitButton ?? Self.default.submitButton
        )
    }
}
