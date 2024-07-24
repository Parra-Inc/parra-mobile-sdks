//
//  ViewDataLoader+Release.swift
//  Parra
//
//  Created by Mick MacCallum on 3/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension ViewDataLoader {
    static func releaseLoader(
        config: ChangelogWidgetConfig
    )
        -> ViewDataLoader<
            Never,
            ReleaseContentObserver.ReleaseContentType,
            ReleaseWidget
        >
    {
        return ViewDataLoader<
            Never,
            ReleaseContentObserver.ReleaseContentType,
            ReleaseWidget
        >(
            renderer: { parra, releaseContent, _ in
                let container: ReleaseWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: ReleaseContentObserver.InitialParams(
                            contentType: releaseContent,
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
