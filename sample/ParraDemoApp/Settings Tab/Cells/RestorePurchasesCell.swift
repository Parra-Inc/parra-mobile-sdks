//
//  RestorePurchasesCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 06/11/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
//

import Parra
import SwiftUI
import StoreKit

struct RestorePurchasesCell: View {
    @Environment(\.parraUserEntitlements) private var userEntitlements

    var body: some View {
        Button {
            userEntitlements.restorePurchases()
        } label: {
            ListItemLabel(
                text: "Restore Purchases",
                symbol: "arrow.clockwise"
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        RestorePurchasesCell()
    }
}
