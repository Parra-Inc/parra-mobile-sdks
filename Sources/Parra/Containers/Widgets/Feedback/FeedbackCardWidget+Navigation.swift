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
                    config: ImageButtonConfig(
                        style: .primary,
                        size: .smallSquare
                    ),
                    content: contentObserver.content.backButton
                ) {
                    contentObserver.onPressBack()
                }

                Spacer()

                ParraLogo(type: .poweredBy)

                Spacer()

                componentFactory.buildImageButton(
                    variant: .plain,
                    config: ImageButtonConfig(
                        style: .primary,
                        size: .smallSquare
                    ),
                    content: contentObserver.content.forwardButton
                ) {
                    contentObserver.onPressForward()
                }
            }
        }
    }
}
