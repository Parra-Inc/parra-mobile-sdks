//
//  ParraContainerRenderer+changelogs.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func changelogRenderer(
        config: ChangelogWidget.Config,
        parra: Parra,
        data: ParraChangelogInfo,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> ChangelogWidget {
        return parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    appReleaseCollection: data.appReleaseCollection,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: navigationPath
            )
    }
}
