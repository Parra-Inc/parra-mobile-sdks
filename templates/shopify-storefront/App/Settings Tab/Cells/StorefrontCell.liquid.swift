//
//  StorefrontCell.swift
//  {{ app.name.raw }}
//
//  Bootstrapped with ❤️ by Parra on {{ "now" | date: "%m/%d/%Y" }}.
//  Copyright © {{ "now" | date: "%Y" }} {{ tenant.name }}. All rights reserved.
//

import Parra
import ParraStorefront
import SwiftUI

/// This example shows how you can perform a sheet presentation of the
/// ``ParraStorefrontWidget`` component. This feature is currently experimental!
struct StorefrontCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isPresented = false

    var body: some View {
        Button(action: {
            isPresented = true
        }) {
            Label(
                title: {
                    Text("Shopify Storefront")
                        .foregroundStyle(Color.primary)
                },
                icon: {
                    if isPresented {
                        ProgressView()
                    } else {
                        Image(systemName: "storefront")
                    }
                }
            )
        }
        .disabled(isPresented)
        .presentParraStorefront(
            isPresented: $isPresented,
            config: ParraStorefrontWidgetConfig(
                // A Shopify storefront can not be presented without defining your
                // Shopify domain and API key.
                shopifyDomain: "{{ shopify.domain }}",
                shopifyApiKey: "{{ shopify.api_key }}",
                showDismissButton: true
            )
        )
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}
