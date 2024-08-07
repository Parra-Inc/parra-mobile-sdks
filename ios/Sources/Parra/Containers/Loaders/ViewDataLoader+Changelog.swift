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

extension ViewDataLoader {
    static func changelogLoader(
        config: ParraChangelogWidgetConfig
    )
        -> ViewDataLoader<
            ChangelogParams,
            ParraChangelogInfo,
            ChangelogWidget
        >
    {
        return ViewDataLoader<
            ChangelogParams,
            ParraChangelogInfo,
            ChangelogWidget
        >(
            renderer: { parra, params, _ in
                let container: ChangelogWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: .init(
                            appReleaseCollection: params.appReleaseCollection,
                            api: parra.parraInternal.api
                        ),
                        config: config,
                        contentTransformer: nil
                    )

                return container
            }
        )
    }
}
