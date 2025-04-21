//
//  CreatorUpdateCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 3/31/25.
//

import SwiftUI
import Parra

struct CreatorUpdateCell: View {
    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "Post to Feed",
            symbol: "megaphone"
        )
        .presentParraCreatorUpdateComposer(
            feedId: "9eb21296-2298-4636-8573-a6969e29a19e",
            presentationState: $presentationState
        )
    }
}
