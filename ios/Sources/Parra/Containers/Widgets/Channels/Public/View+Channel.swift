//
//  View+Channel.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/25.
//

import SwiftUI

private let logger = Logger()

public extension View {
    @MainActor
    func presentParraChannelWidget(
        channelId: String,
        presentationState: Binding<ParraSheetPresentationState>,
        config: ParraChannelConfiguration = .default,
        onDismiss: ((ParraSheetDismissType) -> Void)? = nil
    ) -> some View {
        let transformParams = ChannelTransformParams(
            channelId: channelId
        )

        let transformer: ParraViewDataLoader<
            ChannelTransformParams,
            ChannelParams,
            ChannelWidget
        >.Transformer = { parra, transformParams in
            logger.debug("Applying transformer to present Channel Widget")

            let api = parra.parraInternal.api

            let channel = try await api.getChannel(
                by: transformParams.channelId,
                lastMessageId: nil
            )

            logger.debug("Successfully received channel")

            return ChannelParams(
                channel: channel
            )
        }

        return loadAndPresentSheet(
            name: "channel",
            presentationState: presentationState,
            transformParams: transformParams,
            transformer: transformer,
            with: .channelLoader(
                config: config
            ),
            showDismissButton: false,
            onDismiss: onDismiss
        )
    }
}
