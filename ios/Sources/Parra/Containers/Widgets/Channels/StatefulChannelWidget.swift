//
//  StatefulChannelWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/25.
//

import SwiftUI

struct StatefulChannelWidget: View {
    // MARK: - Lifecycle

    init(
        config: ParraChannelConfiguration,
        params: PaidDirectMessageParams,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self.params = params
        _navigationPath = navigationPath
    }

    // MARK: - Internal

    let config: ParraChannelConfiguration
    let params: PaidDirectMessageParams
    @Binding var navigationPath: NavigationPath

    var body: some View {
        content
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAppInfo) private var appInfo

    @ViewBuilder private var content: some View {
        switch params.presentationMode {
        case .channelList(let channelType, let channelsResponse):
            let container: ChannelListWidget = parra.parraInternal
                .containerRenderer
                .renderContainer(
                    params: ChannelListWidget.ContentObserver.InitialParams(
                        config: config,
                        channelType: channelType,
                        channelsResponse: channelsResponse,
                        requiredEntitlement: params.requiredEntitlement,
                        context: params.context,
                        api: parra.parraInternal.api
                    ),
                    config: config,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
        case .channel(let channel):
            let container: ChannelWidget = parra.parraInternal
                .containerRenderer
                .renderContainer(
                    params: ChannelWidget.ContentObserver.InitialParams(
                        config: config,
                        channel: channel,
                        requiredEntitlement: params.requiredEntitlement,
                        context: params.context,
                        api: parra.parraInternal.api
                    ),
                    config: config,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
        case .paywall(let paywall, let paywallProducts):
            let container: PaywallWidget = parra.parraInternal
                .containerRenderer.renderContainer(
                    params: PaywallWidget.ContentObserver.InitialParams(
                        paywallId: paywall.id,
                        iapType: paywall.iapType,
                        paywallProducts: paywallProducts,
                        marketingContent: paywall.marketingContent,
                        sections: paywall.sections,
                        config: config.paywallConfig ?? .default,
                        api: parra.parraInternal.api,
                        appInfo: appInfo
                    ),
                    config: config.paywallConfig ?? .default,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
        }
    }
}
