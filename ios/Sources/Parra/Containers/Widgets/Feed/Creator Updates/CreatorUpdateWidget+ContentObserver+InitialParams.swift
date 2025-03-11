//
//  CreatorUpdateWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 9/25/24.
//

import SwiftUI

extension CreatorUpdateWidget.ContentObserver {
    struct InitialParams {
        let feedId: String
        let config: ParraCreatorUpdateConfiguration
        let templates: [CreatorUpdateTemplate]
        let api: API
    }
}
