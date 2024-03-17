//
//  ChangelogSample.swift
//  Sample
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can use your own custom logic for determining how
/// and when to present a Parra Feedback Form. The steps to achieve this are:
///
/// 1. Create an `@State` variable to control the presentation state of the
///    changelog.
/// 2. Pass the `isPresented` binding to the `presentParraChangelog` modifier.
/// 3. When you're ready to present the changelog, update the value of
///    `isPresented` to `true`. The changelog will be fetched and
///    presented automatically.
struct ChangelogSample: View {
    @State var isPresented = false // #1

    var body: some View {
        VStack {
            Button("Fetch and present changelog") {
                isPresented = true // #3
            }
        }
        .presentParraChangelog(
            isPresented: $isPresented // #2
        )
    }
}

#Preview {
    ParraAppPreview {
        ChangelogSample()
    }
}
