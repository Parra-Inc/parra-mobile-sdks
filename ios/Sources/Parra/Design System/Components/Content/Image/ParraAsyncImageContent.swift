//
//  AsyncImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraAsyncImageContent: Hashable, Equatable {
    // MARK: - Lifecycle

    init(
        url: URL,
        originalSize: ParraSize? = nil
    ) {
        self.url = url
        self.originalSize = originalSize
    }

    // MARK: - Internal

    let url: URL
    let originalSize: ParraSize?
}
