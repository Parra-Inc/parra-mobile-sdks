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
                    config: ImageButtonConfig(
                        type: .primary,
                        size: .smallSquare,
                        variant: .plain
                    ),
                    content: contentObserver.content.backButton
                ) {
                    contentObserver.onPressBack()
                }

                Spacer()

                ParraLogo(type: .poweredBy)

                Spacer()

                componentFactory.buildImageButton(
                    config: ImageButtonConfig(
                        type: .primary,
                        size: .smallSquare,
                        variant: .plain
                    ),
                    content: contentObserver.content.forwardButton
                ) {
                    contentObserver.onPressForward()
                }
            }
        }
    }
}
