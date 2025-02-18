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
        var channels: [ParraChatChannelType: [Channel]] = [:]

        for type in ParraChatChannelType.allCases {
            channels[type] = []
        }

        self.channelsByType = channels
    }

    deinit {}

    // MARK: - Internal

    static let shared = ParraChannelManager()

    func allChannels(with type: ParraChatChannelType) -> [Channel] {
        return channelsByType[type] ?? []
    }

    // MARK: - Private

    private var channelsByType: [ParraChatChannelType: [Channel]]
}
