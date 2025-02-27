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
    @State private var upsellPresentationState: ParraSheetPresentationState = .ready
    @State private var managePresentationState: ParraSheetPresentationState = .ready

    @Environment(\.parraUserEntitlements) private var userEntitlements

    @MainActor
    @ViewBuilder
    private var button: some View {
        let hasPremium = userEntitlements.hasEntitlement(
            for: PremiumEntitlementKey
        )

        if hasPremium {
            ListItemLoadingButton(
                presentationState: $managePresentationState,
                text: "Manage Subscription",
                symbol: "creditcard"
            )
        } else {
            ListItemLoadingButton(
                presentationState: $upsellPresentationState,
                text: "Become a subscriber",
                symbol: "crown"
            )
        }
    }

    var body: some View {
        button.presentParraPaywall(
            entitlement: PremiumEntitlementKey,
            context: "settings",
            presentationState: $upsellPresentationState
        )
        .manageSubscriptionsSheet(
            isPresented: .init(
                get: {
                    return managePresentationState == .loading
                },
                set: { newValue in
                    if !newValue {
                        managePresentationState = .ready
                    }
                }
            )
        )
    }
}
