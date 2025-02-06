//
//  FaqCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 02/06/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
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
