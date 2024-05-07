//
//  ImageComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol ImageComponentType: View {
    var content: ParraImageContent { get }
    var attributes: ParraAttributes.Image { get }

    init(
        content: ParraImageContent,
        attributes: ParraAttributes.Image
    )
}
