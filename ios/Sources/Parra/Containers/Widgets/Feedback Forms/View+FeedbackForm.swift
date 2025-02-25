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
        presentationState: Binding<ParraSheetPresentationState>,
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
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .feedbackFormLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }

    /// Automatically displays a Feedback Form in a sheet when the `formBinding`
    /// parameter becomes non-nil.
    @MainActor
    func presentParraFeedbackFormWidget(
        with dataBinding: Binding<ParraFeedbackForm?>,
        config: ParraFeedbackFormWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentSheetWithData(
            data: dataBinding,
            config: config,
            with: ParraContainerRenderer.feedbackFormRenderer,
            onDismiss: onDismiss
        )
    }

    @MainActor
    internal func presentParraFeedbackFormWidget(
        with dataBinding: Binding<ParraFeedbackFormDataStub?>,
        config: ParraFeedbackFormWidgetConfig = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackFormWidget(
            with: .init(
                get: {
                    if let stub = dataBinding.wrappedValue {
                        return ParraFeedbackForm(from: stub)
                    }

                    return nil
                },
                set: { form in
                    if form == nil {
                        dataBinding.wrappedValue = nil
                    }
                }
            ),
            config: config,
            onDismiss: onDismiss
        )
    }
}
