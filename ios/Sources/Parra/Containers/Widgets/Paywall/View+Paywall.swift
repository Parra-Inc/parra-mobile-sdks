//
//  View+Paywall.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

public extension View {
    /// Automatically fetches the feed with the provided id and
    /// presents it in a sheet based on the value of the `isPresented` binding.
    @MainActor
    func presentParraPaywall(
        for entitlement: String,
        context: String? = nil,
        isPresented: Binding<Bool>,
        config: ParraPaywallConfig = .default
    ) -> some View {
        let transformParams = PaywallTransformParams(
            entitlement: entitlement,
            context: context
        )

        let transformer: ParraViewDataLoader<
            PaywallTransformParams,
            PaywallParams,
            PaywallWidget
        >.Transformer = { parra, transformParams in
            let response = try await parra.parraInternal.api.getPaywall(
                for: transformParams.entitlement,
                context: transformParams.context
            )

            let appInfo = await parra.parraInternal.appInfoManager
                .cachedAppInfo() ?? .default

            let paywallProducts: PaywallProducts = if let productIds = response
                .productIds
            {
                try await .products(Product.products(for: productIds))
            } else if let groupId = response.groupId {
                .groupId(groupId)
            } else {
                .productIds([])
            }

            return PaywallParams(
                id: response.id,
                paywallProducts: paywallProducts,
                marketingContent: response.marketingContent,
                appInfo: appInfo
            )
        }

        return loadAndPresentSheet(
            loadType: .init(
                get: {
                    if isPresented.wrappedValue {
                        return .transform(transformParams, transformer)
                    } else {
                        return nil
                    }
                },
                set: { type in
                    if type == nil {
                        isPresented.wrappedValue = false
                    }
                }
            ),
            with: .paywallLoader(
                config: config
            ),
            onDismiss: nil
        )
    }
}
