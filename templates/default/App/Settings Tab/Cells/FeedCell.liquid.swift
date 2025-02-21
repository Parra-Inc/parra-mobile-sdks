//
//  FeedCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI

/// This example shows how you can perform a sheet presentation of the
/// ``ParraFeedView`` component. This feature is currently experimental!
struct FeedCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isPresented = false

    var body: some View {
        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "Social Feed",
            symbol: "megaphone"
        )
        .presentParraFeedWidget(
            by: "content",
            isPresented: $isPresented
        )
    }
}

#Preview {
    ParraAppPreview {
        FeedCell()
    }
}
