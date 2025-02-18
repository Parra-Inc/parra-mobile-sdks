//
//  ViewDataLoader+Channels.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/25.
//

import SwiftUI

private let logger = Logger()

struct PaidDirectMessageParams: Equatable {
    enum PresentationMode: Equatable {
        case channelList(
            _ channelType: ParraChatChannelType,
            _ channelListResponse: ChannelCollectionResponse
        )

        case channel(
            _ channel: Channel
        )

        case paywall(
            _ paywall: ParraAppPaywall,
            _ paywallProducts: PaywallProducts
        )
    }

    let key: String
    let requiredEntitlement: String
    let context: String?
    let presentationMode: PresentationMode
}

struct PaidDirectMessageTransformParams: Equatable {
    let key: String
}

struct ChannelListParams: Equatable {
    let channelType: ParraChatChannelType
    let channelsResponse: ChannelCollectionResponse
    let requiredEntitlement: String
    let context: String?
}

struct ChannelListTransformParams: Equatable {
    let channelType: ParraChatChannelType
}

extension ParraViewDataLoader {
    static func channelListLoader(
        channelType: ParraChatChannelType,
        config: ParraChannelConfiguration
    ) -> ParraViewDataLoader<
        ChannelListTransformParams,
        ChannelListParams,
        ChannelListWidget
    > {
        return ParraViewDataLoader<
            ChannelListTransformParams,
            ChannelListParams,
            ChannelListWidget
        >(
            renderer: { parra, params, navigationPath, _ in
                let container: ChannelListWidget = parra.parraInternal
                    .containerRenderer
                    .renderContainer(
                        params: ChannelListWidget.ContentObserver.InitialParams(
                            config: config,
                            channelType: params.channelType,
                            channelsResponse: params.channelsResponse,
                            requiredEntitlement: params.requiredEntitlement,
                            context: params.context,
                            api: parra.parraInternal.api
                        ),
                        config: config,
                        contentTransformer: nil,
                        navigationPath: navigationPath
                    )

                return container
            }
        )
    }

    static func statefulChannelLoader(
        key: String,
        config: ParraChannelConfiguration
    ) -> ParraViewDataLoader<
        PaidDirectMessageTransformParams,
        PaidDirectMessageParams,
        StatefulChannelWidget
    > {
        return ParraViewDataLoader<
            PaidDirectMessageTransformParams,
            PaidDirectMessageParams,
            StatefulChannelWidget
        >(
            renderer: { _, params, navigationPath, _ in
                StatefulChannelWidget(
                    config: config,
                    params: params,
                    navigationPath: navigationPath
                )
            }
        )
    }
}
