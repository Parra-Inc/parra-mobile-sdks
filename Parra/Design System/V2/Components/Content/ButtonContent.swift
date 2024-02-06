//
//  ButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ButtonContent {
    internal let title: LabelContent
    internal let isDisabled: Bool

    internal var onPress: (() -> Void)?

    internal init(
        title: LabelContent,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.onPress = onPress
    }
}
