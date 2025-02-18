//
//  ChannelListWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ChannelListWidget.ContentObserver {
    struct InitialParams {
        let config: ParraChannelConfiguration
        let channelType: ParraChatChannelType
        let channelsResponse: ChannelCollectionResponse?
        let requiredEntitlement: String
        let context: String?
        let api: API
    }
}
