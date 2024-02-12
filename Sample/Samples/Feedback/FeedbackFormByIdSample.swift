//
//  FeedbackFormByIdSample.swift
//  Sample
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    feedback form.
/// 2. Pass the identifier of the form you wish to present and the isPresented
///    binding to the `presentParraFeedbackForm` modifier.
/// 3. When you're ready to present the form, update the value of `isPresented`
///    to `true`. The form will be fetched and presented automatically.
struct FeedbackFormByIdSample: View {
    @State var isPresented = false // #1

    var body: some View {
        VStack {
            Button("Fetch and present feedback form") {
                isPresented = true
            }
        }
        .presentParraFeedbackForm( // #2
            by: "c15256c2-d21d-4d9f-85ac-1d4655416a95",
            isPresented: $isPresented
        )
    }
}

#Preview {
    ParraPreviewApp {
        FeedbackFormByIdSample()
    }
}
