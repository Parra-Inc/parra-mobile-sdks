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
        config: ParraFeedbackFormWidgetConfig
    ) -> ParraViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget> {
        return ParraViewDataLoader<String, ParraFeedbackForm, FeedbackFormWidget>(
            renderer: { parra, data, navigationPath, dismisser in
                return ParraContainerRenderer.feedbackFormRenderer(
                    config: config,
                    parra: parra,
                    data: data,
                    navigationPath: navigationPath,
                    dismisser: dismisser
                )
            }
        )
    }
}
