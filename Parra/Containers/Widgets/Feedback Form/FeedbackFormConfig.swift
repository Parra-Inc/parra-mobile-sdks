//
//  FeedbackFormConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct FeedbackFormConfig: ContainerConfig {
    let title: LabelConfig
    let description: LabelConfig

    /// Any dynamic "select" fields
    let selectFields: LabelConfig

    /// Any dynamic "text" fields
    let textFields: LabelConfig

    let submitButton: ButtonConfig
}
