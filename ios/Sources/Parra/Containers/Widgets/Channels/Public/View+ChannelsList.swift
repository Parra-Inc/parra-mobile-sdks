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
        for channelType: ParraChatChannelType,
        requiredEntitlement entitlement: ParraEntitlement,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        return presentParraChannelsListWidget(
            for: channelType,
            requiredEntitlement: entitlement.key,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraChannelsListWidget<EntitlementKey>(
        for channelType: ParraChatChannelType,
        requiredEntitlement entitlement: EntitlementKey,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View where EntitlementKey: RawRepresentable,
        EntitlementKey.RawValue == String
    {
        return presentParraChannelsListWidget(
            for: channelType,
            requiredEntitlement: entitlement.rawValue,
            context: context,
            isPresented: isPresented,
            config: config,
            onDismiss: onDismiss
        )
    }

    @MainActor
    func presentParraChannelsListWidget(
        for channelType: ParraChatChannelType,
        requiredEntitlement entitlement: String,
        context: String?,
        isPresented: Binding<Bool>,
        config: ParraChannelConfiguration = .default,
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
            let channelListResponse = try await parra.parraInternal.api.paginateChannels(
                type: .paidDm,
                limit: nil,
                offset: nil
            )

            return ChannelListParams(
                channelType: transformParams.channelType,
                channelsResponse: channelListResponse,
                requiredEntitlement: entitlement,
                context: context
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
            with: .channelListLoader(
                channelType: channelType,
                config: config
            ),
            onDismiss: onDismiss
        )
    }
}
