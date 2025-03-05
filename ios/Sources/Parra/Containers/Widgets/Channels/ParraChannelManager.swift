//
//  ParraChannelManager.swift
//  Parra
//
//  Created by Mick MacCallum on 2/17/25.
//

import Combine
import SwiftUI

private let logger = ParraLogger(category: "Parra Channel Manager")

@Observable
final class ParraChannelManager {
    // MARK: - Lifecycle

    init() {
        let channelInfoCache = ParraUserDefaultsStorageModule<[String: ChannelInfo]>(
            key: Constant.channelInfoKey,
            jsonEncoder: .parraEncoder,
            jsonDecoder: .parraDecoder
        )

        self.channelInfoCache = channelInfoCache
        self.cache = channelInfoCache.read() ?? [:]
    }

    deinit {}

    // MARK: - Internal

    enum Constant {
        static let channelInfoKey = "channel_info"
    }

    struct ChannelInfo: Codable {
        struct ViewedMessage: Codable {
            var id: String
            var memberId: String
            var createdAt: Date
        }

        var newestViewedMessage: ViewedMessage?
    }

    static let shared = ParraChannelManager()

    /// The channel that is currently being viewed by the user.
    var visibleChannelId: String?

    var visibleChannelsListIds: [String]?

    /// Whether a channel list capable of pushing to a supplied channel is
    /// currently visible.
    func canPushChannel(with id: String) -> Bool {
        guard let visibleChannelsListIds else {
            return false
        }

        return visibleChannelsListIds.contains(id)
    }

    func updateVisibleChannelsListIds(
        from channels: [Channel]
    ) {
        if channels.isEmpty {
            visibleChannelsListIds = nil
        } else {
            visibleChannelsListIds = channels.map(\.id)
        }
    }

    func newestViewedMessage(
        for channel: Channel
    ) -> ChannelInfo.ViewedMessage? {
        return cache[channel.id]?.newestViewedMessage
    }

    func viewMessage(
        _ message: Message,
        for channel: Channel
    ) {
        if var channelInfo = cache[channel.id],
           var messageInfo = channelInfo.newestViewedMessage
        {
            // Just viewed a message newer than the previous one.
            if message.createdAt > messageInfo.createdAt {
                messageInfo.createdAt = message.createdAt
                messageInfo.id = message.id

                channelInfo.newestViewedMessage = messageInfo

                logger.debug(
                    "Most recent viewed message changed",
                    [
                        "channelId": channel.id,
                        "messageId": message.id
                    ]
                )

                cache[channel.id] = channelInfo
            }
        } else {
            cache[channel.id] = ChannelInfo(
                newestViewedMessage: ChannelInfo.ViewedMessage(
                    id: message.id,
                    memberId: message.memberId,
                    createdAt: message.createdAt
                )
            )
        }
    }

    // MARK: - Private

    private let channelInfoCache: ParraUserDefaultsStorageModule<[String: ChannelInfo]>

    private var cache: [String: ChannelInfo] {
        didSet {
            do {
                try channelInfoCache.write(value: cache)
            } catch {
                logger.error("Error writing channel info cache update", error)
            }
        }
    }
}
