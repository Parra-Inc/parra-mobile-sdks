//
//  Container+DefaultConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/30/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension Container {
    @MainActor
    func defaultTextStyle(
        with updates: TextStyle = TextStyle()
    ) -> TextStyle {
        return TextStyle().withUpdates(
            updates: updates
        )
    }
}
