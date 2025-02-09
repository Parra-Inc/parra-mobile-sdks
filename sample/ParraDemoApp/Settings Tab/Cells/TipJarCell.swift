//
//  TipJarCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 02/06/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct TipJarCell: View {
    @State private var isPresented = false

    var body: some View {
        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "Leave a tip",
            symbol: "heart"
        )
        .presentParraTipJar(
            with: [
                "tip_jar_099",
                "tip_jar_299",
                "tip_jar_999"
            ],
            isPresented: $isPresented,
            config: .default
        )
    }
}

#Preview {
    ParraAppPreview {
        TipJarCell()
    }
}
