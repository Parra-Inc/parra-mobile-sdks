//
//  ParraContainerRenderer+releases.swift
//  Parra
//
//  Created by Mick MacCallum on 2/25/25.
//

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func releaseRenderer(
        config: ReleaseWidget.Config,
        parra: Parra,
        data: ReleaseContentObserver.ReleaseContentType,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> ReleaseWidget {
        return parra.parraInternal
            .containerRenderer.renderContainer(
                params: .init(
                    contentType: data,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: nil,
                navigationPath: navigationPath
            )
    }
}
