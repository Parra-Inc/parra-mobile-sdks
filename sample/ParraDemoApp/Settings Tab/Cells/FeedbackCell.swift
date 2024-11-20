//
//  FeedbackCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/20/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form.
struct FeedbackCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isPresented = false

    var body: some View {
        if let formId = parraAppInfo.application.defaultFeedbackFormId {
            ListItemLoadingButton(
                isLoading: $isPresented,
                text: "Leave Feedback",
                symbol: "quote.bubble"
            )
            .presentParraFeedbackFormWidget(
                by: formId,
                isPresented: $isPresented
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}
