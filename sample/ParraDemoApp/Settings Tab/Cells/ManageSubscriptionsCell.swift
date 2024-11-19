//
//  ManageSubscriptionsCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 11/19/2024.
//  Copyright © 2024 Parra Inc.. All rights reserved.
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
