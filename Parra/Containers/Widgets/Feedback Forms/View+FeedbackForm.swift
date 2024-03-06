//
//  View+FeedbackForm.swift
//  Parra
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraFeedbackForm(
        by formId: String,
        isPresented: Binding<Bool>,
        config: FeedbackFormWidgetConfig = .default,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(formId)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .feedbackFormLoader(
                config: config,
                localFactory: localFactory,
                submissionType: .default
            ),
            onDismiss: onDismiss
        )
    }

    /// Automatically displays a Feedback Form in a sheet when the `formBinding`
    /// parameter becomes non-nil.
    @MainActor
    func presentParraFeedbackForm(
        with formBinding: Binding<ParraFeedbackForm?>,
        config: FeedbackFormWidgetConfig = .default,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackForm(
            with: formBinding,
            config: config,
            submissionType: .default,
            localFactory: localFactory,
            onDismiss: onDismiss
        )
    }

    /// Should stay internal only. Allows changing submisson type to custom
    /// submission handler, which is useful in places like
    @MainActor
    internal func presentParraFeedbackForm(
        with formBinding: Binding<ParraFeedbackForm?>,
        config: FeedbackFormWidgetConfig,
        submissionType: FeedbackFormSubmissionType,
        localFactory: FeedbackFormWidgetFactory?,
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
                localFactory: localFactory,
                submissionType: .default
            ),
            onDismiss: onDismiss
        )
    }
}
