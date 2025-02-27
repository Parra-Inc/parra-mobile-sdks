//
//  View+PaidDms.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/25.
//

import StoreKit
import SwiftUI

// TODO: Write comment about how "key" is a Paid DM configuration in the dashboard.

private let logger = Logger()

public extension View {
    @MainActor
    func presentParraPaidDirectMessageWidget(
        for key: String,
        requiredEntitlement entitlement: ParraEntitlement,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraPaidDirectMessageWidget(
            for: key,
            requiredEntitlement: entitlement.key,
            context: context,
            presentationState: presentationState,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraPaidDirectMessageWidget<EntitlementKey>(
        for key: String,
        requiredEntitlement entitlement: EntitlementKey,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where EntitlementKey: RawRepresentable,
        EntitlementKey.RawValue == String
    {
        return presentParraPaidDirectMessageWidget(
            for: key,
            requiredEntitlement: entitlement.rawValue,
            context: context,
            presentationState: presentationState,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraPaidDirectMessageWidget(
        for key: String,
        requiredEntitlement entitlement: String,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let channelType = ParraChatChannelType.paidDm
        let transformParams = ChannelListTransformParams(
            channelType: channelType
        )

        let transformer: ParraViewDataLoader<
            ChannelListTransformParams,
            ChannelListParams,
            ChannelListWidget
        >.Transformer = { parra, _ in
            logger.debug("Applying transformer to present Paid DM Widget")

            let api = parra.parraInternal.api

            let channelListResponse = try await api.listChatChannels(
                type: channelType
            )

            logger.debug("Successfully received channels list", [
                "count": String(channelListResponse.elements.count)
            ])

            var autoPresentation: ChannelListParams.AutoPresentationMode?

            if channelListResponse.elements.isEmpty {
                logger.debug("Channel list is empty.")

                if ParraUserEntitlements.shared.isEntitled(
                    to: entitlement
                ) {
                    logger.debug("User is entitled, creating new channel.")
                    let channel = try await api.createPaidDmChannel(
                        key: key
                    )

                    logger.debug("Channel is created. Presentation mode is channel")

                    autoPresentation = .channel(channel)
                } else {
                    logger.debug("User is not entitled. Presenting paywall.")

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

                    logger
                        .debug(
                            "Paywall successfully fetched. Presentation mode is paywall."
                        )

                    autoPresentation = .paywall(paywall, paywallProducts)
                }
            } else {
                logger.debug("Channel list not empty. Pesentation mode is channelList.")
            }

            return ChannelListParams(
                key: key,
                channelType: channelType,
                channelsResponse: channelListResponse,
                requiredEntitlement: entitlement,
                context: context,
                autoPresentation: autoPresentation
            )
        }

        return loadAndPresentSheet(
            name: "paid-dms",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .channelListLoader(
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
