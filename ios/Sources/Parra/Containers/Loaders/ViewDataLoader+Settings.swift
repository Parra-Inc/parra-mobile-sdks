//
//  ViewDataLoader+Settings.swift
//  Parra
//
//  Created by Mick MacCallum on 11/1/24.
//

import SwiftUI

private let logger = Logger()

struct SettingsParams: Equatable {
    let layoutId: String
    let layout: ParraUserSettingsLayout
}

struct SettingsTransformParams: Equatable {
    let layoutId: String
}

extension ParraViewDataLoader {
    static func settingsLoader(
        config: ParraUserSettingsConfiguration
    )
        -> ParraViewDataLoader<
            SettingsTransformParams,
            SettingsParams,
            UserSettingsWidget
        >
    {
        return ParraViewDataLoader<
            SettingsTransformParams,
            SettingsParams,
            UserSettingsWidget
        >(
            renderer: { parra, params, _ in
                let container: UserSettingsWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: UserSettingsWidget.ContentObserver.InitialParams(
                            layoutId: params.layoutId,
                            layout: params.layout,
                            config: config,
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
