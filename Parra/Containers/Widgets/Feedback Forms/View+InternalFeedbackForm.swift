//
//  View+InternalFeedbackForm.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension View {
    /// Should stay internal only. Allows changing submisson type to custom
    /// submission handler, which is useful in places like
    @MainActor
    func presentParraFeedbackForm(
        with formBinding: Binding<ParraFeedbackForm?>,
        config: FeedbackFormWidgetConfig,
        submissionType: FeedbackFormSubmissionType,
        localBuilder: FeedbackFormWidgetBuilderConfig,
        onDismiss: ((SheetDismissType) -> Void)?
    ) -> some View {
        loadAndPresentSheet(
            loadType: .init(
                get: {
                    if let form = formBinding.wrappedValue {
                        return .raw(form)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        formBinding.wrappedValue = nil
                    }
                }
            ),
            with: .feedbackFormLoader(
                config: config,
                localBuilder: localBuilder,
                submissionType: .default
            ),
            onDismiss: onDismiss
        )
    }
}
