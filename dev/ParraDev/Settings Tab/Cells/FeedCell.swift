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

    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "Social Feed",
            symbol: "list.bullet.rectangle.portrait"
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
