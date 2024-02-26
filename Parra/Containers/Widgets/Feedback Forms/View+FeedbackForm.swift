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
                onDismiss: onDismiss
            )
        )
    }

    @MainActor
    func presentParraFeedbackForm(
        with form: Binding<ParraFeedbackFormResponse?>,
        localFactory: FeedbackFormWidgetFactory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
        modifier(
            FeedbackFormLoader(
                initialState: Binding<FeedbackFormLoader.FormState>(get: {
                    if let data = form.wrappedValue {
                        FeedbackFormLoader.FormState.form(data)
                    } else {
                        FeedbackFormLoader.FormState.initial
                    }
                }, set: { state in
                    switch state {
                    case .form(let f):
                        form.wrappedValue = f
                    case .formId, .initial, .loading, .error:
                        form.wrappedValue = nil
                    }
                }),
                localFactory: localFactory,
                onDismiss: onDismiss
            )
        )
    }
}
