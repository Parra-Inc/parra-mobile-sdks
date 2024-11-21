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
    @State private var isUpsellPresented = false
    @State private var isManagePresented = false

    @Environment(\.parraUserEntitlements) private var userEntitlements

    @MainActor
    @ViewBuilder
    private var button: some View {
        let hasPremium = userEntitlements.hasEntitlement(
            for: PremiumEntitlementKey
        )

        if hasPremium {
            ListItemLoadingButton(
                isLoading: $isManagePresented,
                text: "Manage Subscription",
                symbol: "creditcard"
            )
        } else {
            ListItemLoadingButton(
                isLoading: $isUpsellPresented,
                text: "Become a subscriber",
                symbol: "crown"
            )
        }
    }

    var body: some View {
        button.presentParraPaywall(
            entitlement: PremiumEntitlementKey,
            isPresented: $isUpsellPresented,
            config: .default
        )
        .manageSubscriptionsSheet(
            isPresented: $isManagePresented
        )
    }
}
