//
//  ViewDataLoader+Changelog.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChangelogParams: Equatable {
    let limit: Int
    let offset: Int
}

public struct ParraChangelogInfo: Equatable {
    let appReleaseCollection: AppReleaseCollectionResponse
}

extension ParraViewDataLoader {
    static func changelogLoader(
        config: ParraChangelogWidgetConfig
    )
        -> ParraViewDataLoader<
            ChangelogParams,
            ParraChangelogInfo,
            ChangelogWidget
        >
    {
        return ParraViewDataLoader<
            ChangelogParams,
            ParraChangelogInfo,
            ChangelogWidget
        >(
            renderer: { parra, data, navigationPath, dismisser in
                return ParraContainerRenderer.changelogRenderer(
                    config: config,
                    parra: parra,
                    data: data,
                    navigationPath: navigationPath,
                    dismisser: dismisser
                )
            }
        )
    }
}
