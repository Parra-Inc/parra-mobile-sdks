//
//  View+PaidDms.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/25.
//

import StoreKit
import SwiftUI

// TODO: Write comment about how "key" is a Paid DM configuration in the dashboard.

public extension View {
    @MainActor
    func presentParraPaidDirectMessageWidget(
        for key: String,
        requiredEntitlement entitlement: ParraEntitlement,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraPaidDirectMessageWidget(
            for: key,
            requiredEntitlement: entitlement.key,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraPaidDirectMessageWidget<EntitlementKey>(
        for key: String,
        requiredEntitlement entitlement: EntitlementKey,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where EntitlementKey: RawRepresentable,
        EntitlementKey.RawValue == String
    {
        return presentParraPaidDirectMessageWidget(
            for: key,
            requiredEntitlement: entitlement.rawValue,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    @ViewBuilder
    func presentParraPaidDirectMessageWidget(
        for key: String,
        requiredEntitlement entitlement: String,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let channelType = ParraChatChannelType.paidDm
        let transformParams = PaidDirectMessageTransformParams(key: key)

        let transformer: ParraViewDataLoader<
            PaidDirectMessageTransformParams,
            PaidDirectMessageParams,
            ChannelWidget
        >.Transformer = { parra, _ in
            let api = parra.parraInternal.api

            let channelListResponse = try await api.listChatChannels(
                type: channelType
            )

            var presentationMode: PaidDirectMessageParams.PresentationMode

            if channelListResponse.elements.isEmpty {
                if ParraUserEntitlements.shared.isEntitled(
                    to: entitlement
                ) {
                    let channel = try await api.createPaidDmChannel(
                        key: key
                    )

                    presentationMode = .channel(channel)
                } else {
                    let paywall = try await api.getPaywall(
                        for: entitlement,
                        context: context
                    )

                    let paywallProducts: PaywallProducts = if let productIds = paywall
                        .productIds
                    {
                        try await .products(Product.products(for: productIds))
                    } else if let groupId = paywall.groupId {
                        .groupId(groupId)
                    } else {
                        .productIds([])
                    }

                    presentationMode = .paywall(paywall, paywallProducts)
                }
            } else {
                presentationMode = .channelList(
                    channelType,
                    channelListResponse
                )
            }

            return PaidDirectMessageParams(
                key: key,
                requiredEntitlement: entitlement,
                context: context,
                presentationMode: presentationMode
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
            with: .statefulChannelLoader(
                key: key,
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
