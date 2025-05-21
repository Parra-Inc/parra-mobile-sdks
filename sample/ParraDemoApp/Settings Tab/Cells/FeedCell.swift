//
//  FeedCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 05/21/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can perform a sheet presentation of the
/// ``ParraFeedView`` component. This feature is currently experimental!
struct FeedCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "Social Feed",
            symbol: "megaphone"
        )
        .presentParraFeedWidget(
            by: "content",
            presentationState: $presentationState
        )
    }
}

#Preview {
    ParraAppPreview {
        FeedCell()
    }
}
