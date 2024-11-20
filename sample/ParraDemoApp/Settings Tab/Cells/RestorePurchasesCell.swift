//
//  RestorePurchasesCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/20/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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