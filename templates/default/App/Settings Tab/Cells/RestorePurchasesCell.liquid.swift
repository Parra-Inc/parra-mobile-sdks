//
//  RestorePurchasesCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
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
