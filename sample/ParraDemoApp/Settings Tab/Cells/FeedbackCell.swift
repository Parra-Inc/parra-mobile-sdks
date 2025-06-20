//
//  FeedbackCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/11/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
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
