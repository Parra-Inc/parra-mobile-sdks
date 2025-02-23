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
        config: ParraChannelListConfiguration,
        params: PaidDirectMessageParams,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self.params = params
        _navigationPath = navigationPath

        if case .paywall = params.presentationMode {
            _isPresentingPaywall = State(initialValue: true)
        } else {
            _isPresentingPaywall = State(initialValue: false)
        }
    }

    // MARK: - Internal

    let config: ParraChannelListConfiguration
    let params: PaidDirectMessageParams
    @Binding var navigationPath: NavigationPath

    var body: some View {
        content
            .presentParraPaywall(
                entitlement: params.requiredEntitlement,
                context: params.context,
                isPresented: $isPresentingPaywall,
                config: config.defaultChannelConfig.paywallConfig ?? .default
            ) { _ in
            }
    }

    // MARK: - Private

    @State private var isPresentingPaywall: Bool

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
                        key: params.key,
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
                        config: config.defaultChannelConfig,
                        channel: channel,
                        requiredEntitlement: params.requiredEntitlement,
                        context: params.context,
                        api: parra.parraInternal.api
                    ),
                    config: config.defaultChannelConfig,
                    contentTransformer: nil,
                    navigationPath: $navigationPath
                )

            container
        case .paywall(let paywall, let paywallProducts):
            EmptyView()
//            let container: PaywallWidget = parra.parraInternal
//                .containerRenderer.renderContainer(
//                    params: PaywallWidget.ContentObserver.InitialParams(
//                        paywallId: paywall.id,
//                        iapType: paywall.iapType,
//                        paywallProducts: paywallProducts,
//                        marketingContent: paywall.marketingContent,
//                        sections: paywall.sections,
//                        config: config.defaultChannelConfig.paywallConfig ?? .default,
//                        api: parra.parraInternal.api,
//                        appInfo: appInfo
//                    ),
//                    config: config.defaultChannelConfig.paywallConfig ?? .default,
//                    contentTransformer: nil,
//                    navigationPath: $navigationPath
//                )
//
//            container
        }
    }
}
