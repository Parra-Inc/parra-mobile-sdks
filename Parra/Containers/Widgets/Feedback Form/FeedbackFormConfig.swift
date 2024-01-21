//
//  FeedbackFormConfig.swift
//  Parra
//
//  Created by Mick MacCallum on 1/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct FeedbackFormConfig: ContainerConfig {
    let title: TextConfig
    let description: TextConfig

    /// Any dynamic "select" fields
    let selectFields: TextConfig

    /// Any dynamic "text" fields
    let textFields: TextConfig

    let submitButton: ButtonConfig
}
