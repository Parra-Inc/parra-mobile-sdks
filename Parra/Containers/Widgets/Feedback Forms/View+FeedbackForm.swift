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
    /// presents it based on the value of `isPresented`.
    @MainActor
    func presentParraFeedbackForm(
        by id: String,
        isPresented: Binding<Bool>,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
        modifier(
            FeedbackFormLoader(
                initialState: Binding<FeedbackFormLoader.FormState>(get: {
                    if isPresented.wrappedValue {
                        FeedbackFormLoader.FormState.formId(id)
                    } else {
                        FeedbackFormLoader.FormState.initial
                    }
                }, set: { state in
                    switch state {
                    case .form, .loading, .error:
                        isPresented.wrappedValue = true
                    case .formId, .initial:
                        isPresented.wrappedValue = false
                    }
                }),
                localFactory: localFactory,
                submissionType: .default,
                onDismiss: onDismiss
            )
        )
    }

    @MainActor
    func presentParraFeedbackForm(
        with formBinding: Binding<ParraFeedbackForm?>,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraFeedbackForm(
            with: formBinding,
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
        submissionType: FeedbackFormLoader.SubmissionType,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
        modifier(
            FeedbackFormLoader(
                initialState: Binding<FeedbackFormLoader.FormState>(get: {
                    if let form = formBinding.wrappedValue {
                        FeedbackFormLoader.FormState.form(form)
                    } else {
                        FeedbackFormLoader.FormState.initial
                    }
                }, set: { state in
                    switch state {
                    case .form(let form):
                        formBinding.wrappedValue = form
                    case .formId, .initial, .loading, .error:
                        formBinding.wrappedValue = nil
                    }
                }),
                localFactory: localFactory,
                submissionType: submissionType,
                onDismiss: onDismiss
            )
        )
    }
}
