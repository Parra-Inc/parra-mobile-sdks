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
    }

    // MARK: - Internal

    let config: ParraChannelListConfiguration
    let params: PaidDirectMessageParams
    @Binding var navigationPath: NavigationPath

    var body: some View {
        content
            .onAppear {
                // The first time the view appears, if we intended to navigate
                // to a specific channel, push that channel onto the navigation
                // stack.
                if case .channel(let channel) = params.presentationMode,
                   !hasPerformedChannelPush
                {
                    hasPerformedChannelPush = true
                    navigationPath.append(channel)
                }
            }
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraAppInfo) private var appInfo

    @State private var hasPerformedChannelPush = false

    private var modifiedConfig: ParraChannelListConfiguration {
        var modified = config

        if case .paywall = params.presentationMode {
            modified.forcePresentPaywall = true
        }

        return modified
    }

    @ViewBuilder private var content: some View {
        let channelsResponse: ChannelListResponse? = if case .channelList(
            let response
        ) = params.presentationMode {
            response
        } else {
            nil
        }

        let container: ChannelListWidget = parra.parraInternal
            .containerRenderer
            .renderContainer(
                params: ChannelListWidget.ContentObserver.InitialParams(
                    config: modifiedConfig,
                    key: params.key,
                    channelType: params.channelType,
                    channelsResponse: channelsResponse,
                    requiredEntitlement: params.requiredEntitlement,
                    context: params.context,
                    api: parra.parraInternal.api
                ),
                config: modifiedConfig,
                contentTransformer: nil,
                navigationPath: $navigationPath
            )

        container
    }
}
