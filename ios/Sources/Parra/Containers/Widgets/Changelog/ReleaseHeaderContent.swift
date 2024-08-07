//
//  ReleaseHeaderContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ReleaseHeaderContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init?(_ releaseHeader: ParraReleaseHeader?) {
        guard let releaseHeader else {
            return nil
        }

        guard let url = URL(string: releaseHeader.url) else {
            return nil
        }

        self.id = releaseHeader.id
        self.image = ParraAsyncImageContent(url: url)
        self.size = CGSize(
            width: releaseHeader.size.width,
            height: releaseHeader.size.height
        )
    }

    // MARK: - Public

    public let id: String
    public let size: CGSize
    public let image: ParraAsyncImageContent
}

// MARK: - CGSize + Hashable

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}
