//
//  ButtonContent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ButtonContent {
    // MARK: Lifecycle

    init(
        title: LabelContent,
        isDisabled: Bool = false,
        onPress: (() -> Void)? = nil
    ) {
        self.title = title
        self.isDisabled = isDisabled
        self.onPress = onPress
    }

    // MARK: Public

    public let title: LabelContent
    public let isDisabled: Bool

    public internal(set) var onPress: (() -> Void)?
}
