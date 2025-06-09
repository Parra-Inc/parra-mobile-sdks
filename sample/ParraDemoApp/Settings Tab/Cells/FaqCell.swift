//
//  FaqCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/09/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
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
