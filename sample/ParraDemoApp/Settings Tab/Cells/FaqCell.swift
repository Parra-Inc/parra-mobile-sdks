//
//  FaqCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 12/30/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
//

import SwiftUI
import Parra

struct FaqCell: View {
    @State private var isPresented = false

    var body: some View {
        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "FAQs",
            symbol: "questionmark.bubble"
        )
        .presentParraFAQView(isPresented: $isPresented)
    }
}
