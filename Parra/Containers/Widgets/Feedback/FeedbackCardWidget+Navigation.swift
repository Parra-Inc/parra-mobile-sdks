//
//  FeedbackCardWidget+Navigation.swift
//  Parra
//
//  Created by Mick MacCallum on 2/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackCardWidget {
    @ViewBuilder var navigation: some View {
        if contentObserver.showNavigation {
            HStack(alignment: .center) {
                componentFactory.buildImageButton(
                    variant: .plain,
                    config: config.backButton,
                    content: contentObserver.content.backButton,
                    suppliedFactory: componentFactory.local?.backButton
                )

                Spacer()

                ParraLogo(type: .poweredBy)

                Spacer()

                componentFactory.buildImageButton(
                    variant: .plain,
                    config: config.forwardButton,
                    content: contentObserver.content.forwardButton,
                    suppliedFactory: componentFactory.local?.forwardButton
                )
            }
        }
    }
}
