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
            renderer: { parra, params, _ in
                let container: ChangelogWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        with: localBuilder,
                        params: .init(
                            appReleaseCollection: params.appReleaseCollection,
                            apiResourceServer: parra.parraInternal
                                .apiResourceServer
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
