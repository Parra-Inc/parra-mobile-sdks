//
//  ChannelListWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ChannelListWidget.ContentObserver {
    struct InitialParams {
        let config: ParraChannelListConfiguration
        let key: String
        let channelType: ParraChatChannelType
        let channelsResponse: ChannelListResponse?
        let requiredEntitlement: String
        let context: String?
        let autoPresentation: ChannelListParams.AutoPresentationMode?
        let api: API
    }
}
