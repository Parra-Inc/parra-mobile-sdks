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
        self.image = ParraAsyncImageContent(
            url: url,
            originalSize: releaseHeader.size
        )
        self.size = _ParraSize(
            width: releaseHeader.size.width,
            height: releaseHeader.size.height
        )
    }

    // MARK: - Public

    public let id: String
    public let size: _ParraSize
    public let image: ParraAsyncImageContent
}
