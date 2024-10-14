//
//  ParraAsyncImageContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI
import UIKit

public struct ParraAsyncImageContent: Hashable, Equatable {
    // MARK: - Lifecycle

    public init(
        url: URL,
        originalSize: CGSize? = nil
    ) {
        self.url = url
        self.originalSize = _ParraSize(cgSize: originalSize)
    }

    // MARK: - Internal

    let url: URL
    let originalSize: _ParraSize?
}
