//
//  ParraContainerRenderer+creatorUpdate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

private let logger = Logger()

import SwiftUI

extension ParraContainerRenderer {
    @MainActor
    static func creatorUpdateRenderer(
        config: CreatorUpdateWidget.Config,
        parra: Parra,
        data: CreatorUpdateParams,
        navigationPath: Binding<NavigationPath>,
        dismisser: ParraSheetDismisser?
    ) -> CreatorUpdateWidget {
        return parra.parraInternal
            .containerRenderer
            .renderContainer<CreatorUpdateWidget>(
                params: CreatorUpdateWidget.ContentObserver.InitialParams(
                    feedId: data.feedId,
                    config: config,
                    templates: data.templates,
                    api: parra.parraInternal.api
                ),
                config: config,
                contentTransformer: { contentObserver in
                    contentObserver.submissionHandler = { update in
                        parra.logEvent(.submit(form: "creator_update"), [
                            "updateId": update.id,
                            "title": update.title
                        ])

                        dismisser?(.completed)
                    }
                },
                navigationPath: navigationPath
            )
    }
}
