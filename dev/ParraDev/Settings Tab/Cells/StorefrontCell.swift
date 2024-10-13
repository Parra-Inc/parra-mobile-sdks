//
//  StorefrontCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 10/12/24.
//

import Parra
import ParraStorefront
import SwiftUI

private let shopifyDomain: String = ""
private let shopifyApiKey: String = ""

/// This example shows how you can perform a sheet presentation of the
/// ``ParraStorefrontWidget`` component. This feature is currently experimental!
struct StorefrontCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var isPresented = false

    var body: some View {
        // A Shopify storefront can not be presented without defining your
        // Shopify domain and API key.
        if !shopifyDomain.isEmpty && !shopifyApiKey.isEmpty {
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
                config: ParraStorefrontConfig(
                    shopifyDomain: shopifyDomain,
                    shopifyApiKey: shopifyApiKey,
                    showDismissButton: true
                )
            )
        }
    }
}

#Preview {
    ParraAppPreview {
        FeedbackCell()
    }
}