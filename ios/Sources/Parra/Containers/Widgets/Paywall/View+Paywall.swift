//
//  View+Paywall.swift
//  Parra
//
//  Created by Mick MacCallum on 11/12/24.
//

import StoreKit
import SwiftUI

public extension View {
    /// Presents a sheet that is meant to block the user from accessing content
    /// without an active subscription. Pass the required entitlement to view
    /// the content and an optional context string that allows you to remotely
    /// define the content of the paywall.
    @MainActor
    func presentParraPaywall(
        entitlement: ParraEntitlement,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraPaywallConfig? = nil,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraPaywall(
            entitlement: entitlement.key,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    /// Presents a sheet that is meant to block the user from accessing content
    /// without an active subscription. Pass the required entitlement to view
    /// the content and an optional context string that allows you to remotely
    /// define the content of the paywall.
    @MainActor
    func presentParraPaywall<Key>(
        entitlement key: Key,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraPaywallConfig? = nil,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where Key: RawRepresentable, Key.RawValue == String {
        return presentParraPaywall(
            entitlement: key.rawValue,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    /// Presents a sheet that is meant to block the user from accessing content
    /// without an active subscription. Pass the required entitlement to view
    /// the content and an optional context string that allows you to remotely
    /// define the content of the paywall.
    @MainActor
    func presentParraPaywall(
        entitlement: String,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraPaywallConfig? = nil,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
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
            let paywall = try await parra.parraInternal.api.getPaywall(
                for: transformParams.entitlement,
                context: transformParams.context
            )

            let appInfo = await parra.parraInternal.appInfoManager
                .cachedAppInfo() ?? .default

            let paywallProducts: PaywallProducts = if let productIds = paywall
                .productIds
            {
                try await .products(Product.products(for: productIds))
            } else if let groupId = paywall.groupId {
                .groupId(groupId)
            } else {
                .productIds([])
            }

            Logger.debug("Finished preparing products for paywall", [
                "product_info": paywallProducts.description
            ])

            return PaywallParams(
                id: paywall.id,
                iapType: paywall.iapType,
                paywallProducts: paywallProducts,
                marketingContent: paywall.marketingContent,
                sections: paywall.sections,
                appInfo: appInfo
            )
        }

        let finalConfig: ParraPaywallConfig = if let config {
            config
        } else {
            ParraPaywallConfig.defaultConfig(for: entitlement) ?? .default
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
                config: finalConfig
            ),
            detents: [.large],
            onDismiss: onDismiss
        )
    }
}
