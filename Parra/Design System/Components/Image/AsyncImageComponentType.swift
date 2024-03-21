//
//  AsyncImageComponentType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol AsyncImageComponentType: View {
    var content: AsyncImageContent { get }
    var attributes: ImageAttributes { get }

    init(
        content: AsyncImageContent,
        attributes: ImageAttributes
    )
}
