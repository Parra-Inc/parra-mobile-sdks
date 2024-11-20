//
//  SubscriptionUpsellCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import SwiftUI
import Parra

private let PremiumEntitlementKey = "premium"

struct SubscriptionUpsellCell: View {
    @State private var isPresented = false

    @Environment(\.parraUserEntitlements) private var userEntitlements

    var body: some View {
        let hasPremium = userEntitlements.hasEntitlement(
            for: PremiumEntitlementKey
        )

        ListItemLoadingButton(
            isLoading: $isPresented,
            text: "Premium Membership",
            symbol: "crown"
        )
        .disabled(hasPremium)
        /// Your `entitlement` ID can be found in the dashboard under
        /// Billing -> Entitlements.
        /// https://parra.io/dashboard/billing/entitlements
        .presentParraPaywall(
            entitlement: PremiumEntitlementKey,
            isPresented: $isPresented,
            config: .default
        )
    }
}
