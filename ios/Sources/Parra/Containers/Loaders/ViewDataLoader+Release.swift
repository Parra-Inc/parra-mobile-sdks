//
//  ViewDataLoader+Release.swift
//  Parra
//
//  Created by Mick MacCallum on 3/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let logger = Logger()

extension ParraViewDataLoader {
    static func releaseLoader(
        config: ParraChangelogWidgetConfig
    )
        -> ParraViewDataLoader<
            Never,
            ReleaseContentObserver.ReleaseContentType,
            ReleaseWidget
        >
    {
        return ParraViewDataLoader<
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
