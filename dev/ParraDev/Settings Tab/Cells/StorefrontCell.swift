//
//  StorefrontCell.swift
//  ParraDev
//
//  Created by Mick MacCallum on 10/12/24.
//

import Parra
import ParraStorefront
import SwiftUI

/// This example shows how you can perform a sheet presentation of the
/// ``ParraStorefrontWidget`` component. This feature is currently experimental!
struct StorefrontCell: View {
    @Environment(\.parra) private var parra
    @Environment(\.parraAppInfo) private var parraAppInfo

    @State private var presentationState: ParraSheetPresentationState = .ready

    var body: some View {
        // A Shopify storefront can not be presented without defining your
        // Shopify domain and API key.
        if ParraStorefront.isInitialized {
            ListItemLoadingButton(
                presentationState: $presentationState,
                text: "Shopify Storefront",
                symbol: "storefront"
            )
            .presentParraStorefront(
                presentationState: $presentationState,
                config: ParraStorefrontWidgetConfig(
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
