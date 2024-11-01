//
//  UserSettingsWidget+ContentObserver+InitialParams.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

extension UserSettingsWidget.ContentObserver {
    struct InitialParams {
        let layoutId: String
        let layout: ParraUserSettingsLayout?
        let config: ParraUserSettingsConfiguration
        let api: API
    }
}
