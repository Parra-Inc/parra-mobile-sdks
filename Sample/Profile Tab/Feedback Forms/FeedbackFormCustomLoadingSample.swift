//
//  FeedbackFormCustomLoadingSample.swift
//  Sample
//
//  Created by Mick MacCallum on 2/12/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
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
struct FeedbackFormCustomLoadingSample: View {
    // MARK: - Internal

    @State var formData: ParraFeedbackForm? // #3
    @State var errorMessage: String?
    @State var isLoading = false

    @Environment(\.parra) var parra // #1

    var body: some View {
        VStack {
            Button(action: {
                loadFeedbackForm(with: "ff66b5d8-9030-4dc3-aca8-50eec3bb9a1e")
            }, label: {
                HStack(spacing: 12) {
                    Text("Fetch feedback form")

                    if isLoading {
                        ProgressView()
                    }
                }
            })
            .disabled(isLoading)
        }
        .presentParraFeedbackForm(with: $formData) // #4
    }

    // MARK: - Private

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

                Logger.error(error)
            }

            isLoading = false
        }
    }
}

#Preview {
    ParraAppPreview {
        FeedbackFormCustomLoadingSample()
    }
}
