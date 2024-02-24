//
//  FeedbackCardWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// TODO: How can the `Factory` type provided to this widget allow overriding
// elements dynamically by card type?

public struct FeedbackCardWidget: Container {
    // MARK: - Public

    public var body: some View {
        VStack {
            // Extra wrapper used to support configuration of padding inside and
            // outside of the content view
            VStack {
                navigation

                content
            }
            .padding(style.contentPadding)
            .applyBackground(style.background)
            .applyCornerRadii(
                size: style.cornerRadius,
                from: themeObserver.theme
            )
        }
        .padding(style.padding)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory<Factory>
    @StateObject var contentObserver: ContentObserver
    let config: Config
    let style: Style

    @EnvironmentObject var themeObserver: ParraThemeObserver

    @ViewBuilder var navigation: some View {
        if contentObserver.content.showNavigation {
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

    @ViewBuilder var content: some View {
        TabView {
            Text("First")
            Text("Second")
            Text("Third")
            Text("Fourth")
        }
        .tabViewStyle(.page)
    }
}

#Preview {
    VStack {
        ParraContainerPreview { componentFactory in
            FeedbackCardWidget(
                componentFactory: componentFactory,
                contentObserver: FeedbackCardWidget.ContentObserver(),
                config: .default,
                style: .default(with: .default)
            )
        }
    }
    .padding()
}
