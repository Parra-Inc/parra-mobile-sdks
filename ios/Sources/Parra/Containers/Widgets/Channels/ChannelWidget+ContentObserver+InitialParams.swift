//
//  ChannelWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension ChannelWidget.ContentObserver {
    struct InitialParams {
        let config: ParraChannelConfiguration
        let channel: Channel
        let api: API
    }
}
