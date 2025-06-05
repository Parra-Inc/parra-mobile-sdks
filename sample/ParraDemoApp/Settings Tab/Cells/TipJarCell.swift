//
//  TipJarCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/05/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI

struct TipJarCell: View {
    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        ListItemLoadingButton(
            presentationState: $presentationState,
            text: "Leave a tip",
            symbol: "heart"
        )
        .presentParraTipJar(
            with: [
                "tip_jar_099",
                "tip_jar_299",
                "tip_jar_999"
            ],
            presentationState: $presentationState,
            config: .default
        )
    }
}

#Preview {
    ParraAppPreview {
        TipJarCell()
    }
}
