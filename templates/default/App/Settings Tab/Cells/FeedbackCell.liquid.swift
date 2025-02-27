//
//  FeedbackCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form.
struct FeedbackCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        if let formId = parraAppInfo.application.defaultFeedbackFormId {
            ListItemLoadingButton(
                presentationState: $presentationState,
                text: "Leave Feedback",
                symbol: "quote.bubble"
            )
            .presentParraFeedbackFormWidget(
                by: formId,
                presentationState: $presentationState
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}
