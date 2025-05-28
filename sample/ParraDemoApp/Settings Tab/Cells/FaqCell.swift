//
//  FaqCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 05/28/2025.
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
