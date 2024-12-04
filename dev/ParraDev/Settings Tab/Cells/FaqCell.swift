//
//  FaqCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 12/3/24.
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
