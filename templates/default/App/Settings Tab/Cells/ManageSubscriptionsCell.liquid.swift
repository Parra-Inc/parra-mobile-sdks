//
//  ManageSubscriptionsCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import SwiftUI
import StoreKit

struct ManageSubscriptionsCell: View {
    @State private var isPresented = false

    var body: some View {
        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "Manage Subscriptions",
            symbol: "creditcard"
        )
        .manageSubscriptionsSheet(isPresented: $isPresented)
    }
}

#Preview {
    ParraAppPreview {
        ManageSubscriptionsCell()
    }
}
