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

struct ChangelogLoaderResult: Equatable {
    let appReleaseCollection: AppReleaseCollectionResponse
}

extension ViewDataLoader {
    static func changelogLoader(
        config: ChangelogWidgetConfig,
        localBuilder: ChangelogWidget.BuilderConfig
    )
        -> ViewDataLoader<
            ChangelogParams,
            ChangelogLoaderResult,
            ChangelogWidget
        >
    {
        return ViewDataLoader<
            ChangelogParams,
            ChangelogLoaderResult,
            ChangelogWidget
        >(
            loader: { parra, transformParams in
                let response = try await parra.networkManager.paginateReleases(
                    limit: transformParams.limit,
                    offset: transformParams.offset
                )

                return ChangelogLoaderResult(
                    appReleaseCollection: response
                )
            },
            renderer: { parra, params, _ in
                let container: ChangelogWidget = renderContainer(
                    from: parra,
                    with: localBuilder,
                    params: .init(
                        appReleaseCollection: params.appReleaseCollection,
                        networkManager: parra.networkManager
                    ),
                    config: config
                ) { _ in
                    // TODO: Dismisser set on container.contentObserver?
                }

                return container
            }
        )
    }
}
