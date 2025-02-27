//
//  FaqCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI
import Parra

struct FaqCell: View {
    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "FAQs",
            symbol: "questionmark.bubble"
        )
        .presentParraFAQView(presentationState: $presentationState)
    }
}
