//
//  FeedbackCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 09/09/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Access the Parra instance attached to your app using `@Environment`.
/// 2. Use the ``parra`` instance to fetch the form data for the provided
///    form id.
/// 3. Store the feedback form data in `@State`
/// 4. Use the `presentParraFeedbackForm` modifier and pass the form state as a
///    parameter. When it becomes non nil, the form is presented.
struct FeedbackCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var formData: ParraFeedbackForm? // #3
    @State private var errorMessage: String?
    @State private var isLoading = false

    var body: some View {
        if let formId = parraAppInfo.application.defaultFeedbackFormId {
            Button(action: {
                loadFeedbackForm(with: formId)
            }) {
                Label(
                    title: {
                        Text("Leave Feedback")
                            .foregroundStyle(Color.primary)
                    },
                    icon: {
                        if isLoading {
                            ProgressView()
                        } else {
                            Image(systemName: "quote.bubble")
                        }
                    }
                )
            }
            .disabled(isLoading)
            .presentParraFeedbackForm(with: $formData) // #4
        }
    }

    private func loadFeedbackForm(
        with formId: String
    ) {
        isLoading = true

        Task {
            do {
                errorMessage = nil
                formData = try await parra.feedback.fetchFeedbackForm( // #2
                    formId: formId
                )
            } catch {
                errorMessage = String(describing: error)
                formData = nil

                ParraLogger.error(error)
            }

            isLoading = false
        }
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}
