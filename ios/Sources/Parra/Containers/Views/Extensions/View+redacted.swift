//
//  View+redacted.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public extension View {
    /// default is placeholder type
    @ViewBuilder
    func redacted(
        when shouldRedact: Bool,
        reason: RedactionReasons = RedactionReasons.placeholder
    ) -> some View {
        redacted(
            reason: shouldRedact ? reason : []
        )
    }
}
