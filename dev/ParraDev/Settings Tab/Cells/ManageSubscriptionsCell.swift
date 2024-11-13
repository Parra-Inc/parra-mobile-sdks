//
//  ManageSubscriptionsCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 11/13/24.
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

