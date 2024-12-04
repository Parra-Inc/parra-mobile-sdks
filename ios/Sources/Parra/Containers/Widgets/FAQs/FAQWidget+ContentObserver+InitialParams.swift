//
//  FAQWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

extension FAQWidget.ContentObserver {
    struct InitialParams {
        let layout: ParraAppFaqLayout?
        let config: ParraFAQConfiguration
        let api: API
    }
}
