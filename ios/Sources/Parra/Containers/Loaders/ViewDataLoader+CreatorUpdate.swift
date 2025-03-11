//
//  ViewDataLoader+CreatorUpdate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/6/25.
//

import SwiftUI

private let logger = Logger()

struct CreatorUpdateParams: Equatable {
    let feedId: String
    let templates: [CreatorUpdateTemplate]
}

struct CreatorUpdateTransformParams: Equatable {
    let feedId: String
}

extension ParraViewDataLoader {
    static func creatorUpdate(
        config: ParraCreatorUpdateConfiguration
    )
        -> ParraViewDataLoader<
            CreatorUpdateTransformParams,
            CreatorUpdateParams,
            CreatorUpdateWidget
        >
    {
        return ParraViewDataLoader<
            CreatorUpdateTransformParams,
            CreatorUpdateParams,
            CreatorUpdateWidget
        >(
            renderer: { parra, data, navigationPath, dismisser in
                return ParraContainerRenderer.creatorUpdateRenderer(
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
