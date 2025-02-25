//
//  View+ChannelsList.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/25.
//

import SwiftUI

public extension View {
    @MainActor
    func presentParraChannelsListWidget(
        for key: String,
        channelType: ParraChatChannelType,
        requiredEntitlement entitlement: ParraEntitlement,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraChannelsListWidget(
            for: key,
            channelType: channelType,
            requiredEntitlement: entitlement.key,
            context: context,
            presentationState: presentationState,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraChannelsListWidget<EntitlementKey>(
        for key: String,
        channelType: ParraChatChannelType,
        requiredEntitlement entitlement: EntitlementKey,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where EntitlementKey: RawRepresentable,
        EntitlementKey.RawValue == String
    {
        return presentParraChannelsListWidget(
            for: key,
            channelType: channelType,
            requiredEntitlement: entitlement.rawValue,
            context: context,
            presentationState: presentationState,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraChannelsListWidget(
        for key: String,
        channelType: ParraChatChannelType,
        requiredEntitlement entitlement: String,
        context: String?,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelListConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = ChannelListTransformParams(
            channelType: channelType
        )

        let transformer: ParraViewDataLoader<
            ChannelListTransformParams,
            ChannelListParams,
            ChannelListWidget
        >.Transformer = { parra, transformParams in
            let api = parra.parraInternal.api
            let channelListResponse = try await api.listChatChannels(
                type: .paidDm
            )

            return ChannelListParams(
                key: key,
                channelType: transformParams.channelType,
                channelsResponse: channelListResponse,
                requiredEntitlement: entitlement,
                context: context
            )
        }

        return loadAndPresentSheet(
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
