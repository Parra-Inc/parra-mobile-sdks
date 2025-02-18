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
    func presentParraFeedbackFormWidget(
        by formId: String,
        isPresented: Binding<Bool>,
        config: ParraFeedbackFormWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = formId

        let transformer: ParraViewDataLoader<
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
                submissionType: .default
            ),
            onDismiss: onDismiss
        )
    }

    @MainActor
    internal func presentParraFeedbackFormWidget(
        with formBinding: Binding<ParraFeedbackFormDataStub?>,
        config: ParraFeedbackFormWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackFormWidget(
            with: .init(
                get: {
                    if let stub = formBinding.wrappedValue {
                        return ParraFeedbackForm(from: stub)
                    }

                    return nil
                },
                set: { form in
                    if form == nil {
                        formBinding.wrappedValue = nil
                    }
                }
            ),
            config: config,
            onDismiss: onDismiss
        )
    }

    /// Automatically displays a Feedback Form in a sheet when the `formBinding`
    /// parameter becomes non-nil.
    @MainActor
    func presentParraFeedbackFormWidget(
        with formBinding: Binding<ParraFeedbackForm?>,
        config: ParraFeedbackFormWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackFormWidget(
            with: formBinding,
            config: config,
            submissionType: .default,
            onDismiss: onDismiss
        )
    }
}
