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
        localBuilder: FeedbackFormWidgetBuilderConfig = .init(),
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = formId

        let transformer: ViewDataLoader<
            String,
            ParraFeedbackForm,
            FeedbackFormWidget
        >.Transformer = { parra, formId in
            return try await parra.parraInternal.feedback.fetchFeedbackForm(
                formId: formId
            )
        }

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(transformParams, transformer)
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
                localBuilder: localBuilder,
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
        localBuilder: FeedbackFormWidgetBuilderConfig = .init(),
        onDismiss: ((SheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackForm(
            with: formBinding,
            config: config,
            submissionType: .default,
            localBuilder: localBuilder,
            onDismiss: onDismiss
        )
    }
}
