//
//  TextInputComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol TextInputComponentType: View {
    var config: TextInputConfig { get }
    var content: TextInputContent { get }
    var attributes: ParraAttributes.TextInput { get }

    init(
        config: TextInputConfig,
        content: TextInputContent,
        attributes: ParraAttributes.TextInput
    )
}
