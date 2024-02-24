//
//  View+FeedbackCards.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// Automatically fetches the feedback form with the provided id and
    /// presents it based on the value of `isPresented`.
    @MainActor
    @ViewBuilder
    func presentParraFeedbackCards(
        for appArea: ParraQuestionAppArea = .all,
        isPresented: Binding<Bool>,
        modalStyle: ParraCardModalType = .drawer,
        localFactory: FeedbackCardWidget.Factory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
//        modifier(
//            FeedbackFormLoader(
//                initialState: Binding<FeedbackFormLoader.FormState>(get: {
        ////                    if isPresented.wrappedValue {
        ////                        FeedbackFormLoader.FormState.formId(id)
        ////                    } else {
//                    FeedbackFormLoader.FormState.initial
        ////                    }
//                }, set: { state in
//                    switch state {
//                    case .form, .loading, .error:
//                        isPresented.wrappedValue = true
//                    case .formId, .initial:
//                        isPresented.wrappedValue = false
//                    }
//                }),
//                localFactory: localFactory,
//                onDismiss: onDismiss
//            )
//        )
    }

    @MainActor
    @ViewBuilder
    func presentParraFeedbackCards(
        _ cards: Binding<[ParraCardItem]?>,
        modalStyle: ParraCardModalType = .drawer,
        localFactory: FeedbackCardWidget.Factory? = nil,
        onDismiss: ((FeedbackFormDismissType) -> Void)? = nil
    ) -> some View {
//        modifier(
//            FeedbackFormLoader(
//                initialState: Binding<FeedbackFormLoader.FormState>(get: {
        ////                    if let data = form.wrappedValue {
        ////                        FeedbackFormLoader.FormState.form(data)
        ////                    } else {
//                    FeedbackFormLoader.FormState.initial
        ////                    }
//                }, set: { _ in
        ////                    switch state {
        ////                    case .form(let f):
        ////                        form.wrappedValue = f
        ////                    case .formId, .initial, .loading, .error:
        ////                        form.wrappedValue = nil
        ////                    }
//                }),
//                localFactory: localFactory,
//                onDismiss: onDismiss
//            )
//        )
    }
}
