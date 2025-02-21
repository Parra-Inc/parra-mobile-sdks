//
//  SubscriptionUpsellCell.swift
//  Parra Demo
//
//  Bootstrapped with ❤️ by Parra on 02/06/2025.
//  Copyright © 2025 Parra Inc.. All rights reserved.
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
            context: "settings",
            isPresented: $isUpsellPresented
        )
        .manageSubscriptionsSheet(
            isPresented: $isManagePresented
        )
    }
}
