//
//  ImageButtonComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ImageButtonComponentType: View {
    var config: ImageButtonConfig { get }
    var content: ImageButtonContent { get }
    var style: ImageButtonStyle { get }

    init(
        config: ImageButtonConfig,
        content: ImageButtonContent,
        style: ImageButtonStyle,
        onPress: @escaping () -> Void
    )
}
