//
//  FeedCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 9/27/24.
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
