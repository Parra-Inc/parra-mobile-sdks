//
//  ViewDataLoader+FAQs.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

private let logger = Logger()

struct FAQsParams: Equatable {
    let layout: ParraAppFaqLayout
}

struct FAQsTransformParams: Equatable {}

extension ParraViewDataLoader {
    static func faqsLoader(
        config: ParraFAQConfiguration
    )
        -> ParraViewDataLoader<
            FAQsTransformParams,
            FAQsParams,
            FAQWidget
        >
    {
        return ParraViewDataLoader<
            FAQsTransformParams,
            FAQsParams,
            FAQWidget
        >(
            renderer: { parra, params, navigationPath, _ in
                let container: FAQWidget = parra.parraInternal
                    .containerRenderer.renderContainer(
                        params: FAQWidget.ContentObserver.InitialParams(
                            layout: params.layout,
                            config: config,
                            api: parra.parraInternal.api
                        ),
                        config: config,
                        contentTransformer: nil,
                        navigationPath: navigationPath
                    )

                return container
            }
        )
    }
}
