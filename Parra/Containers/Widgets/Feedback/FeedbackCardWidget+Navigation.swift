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
                componentFactory.buildButton(
                    variant: .image,
                    component: \.backButton,
                    config: config.backButton,
                    content: contentObserver.content.backButton
                )

                Spacer()

                ParraLogo(type: .poweredBy)

                Spacer()

                componentFactory.buildButton(
                    variant: .image,
                    component: \.forwardButton,
                    config: config.forwardButton,
                    content: contentObserver.content.forwardButton
                )
            }
        }
    }
}
