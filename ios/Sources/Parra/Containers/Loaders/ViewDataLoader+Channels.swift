//
//  ViewDataLoader+Channels.swift
//  Parra
//
//  Created by Mick MacCallum on 2/14/25.
//

import SwiftUI

private let logger = Logger()

struct ChannelListParams: Equatable {
    enum AutoPresentationMode: Equatable {
        case paywall(
            _ paywall: ParraAppPaywall,
            _ paywallProducts: PaywallProducts
        )

        case channel(_ channel: Channel)
    }

    let key: String
    let channelType: ParraChatChannelType
    let channelsResponse: ChannelListResponse
    let requiredEntitlement: String
    let context: String?
    let autoPresentation: AutoPresentationMode?
}

struct ChannelListTransformParams: Equatable {
    let channelType: ParraChatChannelType
}

extension ParraViewDataLoader {
    static func channelListLoader(
        config: ParraChannelListConfiguration
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
                            key: params.key,
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
}
