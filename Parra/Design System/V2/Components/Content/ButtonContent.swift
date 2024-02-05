//
//  ButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct ButtonContent {
    internal var title: LabelContent
    internal var isDisabled: Bool

    internal var onPress: (() -> Void)?

    init(
        title: LabelContent,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.onPress = onPress
    }
}
