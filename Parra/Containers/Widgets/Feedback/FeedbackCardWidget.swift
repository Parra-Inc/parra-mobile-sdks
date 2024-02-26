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

struct FeedbackCardWidget: Container {
    // MARK: - Lifecycle

    init(
        componentFactory: ComponentFactory<Factory>,
        contentObserver: ContentObserver,
        config: FeedbackCardWidgetConfig,
        style: Style,
        cardDelegate: ParraCardViewDelegate? = nil
    ) {
        self.componentFactory = componentFactory
        self.config = config
        self.style = style
        self.cardDelegate = cardDelegate

        _contentObserver = StateObject(
            wrappedValue: contentObserver
        )
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory<FeedbackCardWidgetFactory>
    @StateObject var contentObserver: ContentObserver
    let config: FeedbackCardWidgetConfig
    let style: FeedbackCardWidgetStyle

    weak var cardDelegate: ParraCardViewDelegate?

    @Environment(Parra.self) var parra
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        VStack {
            // Extra wrapper used to support configuration of padding inside and
            // outside of the content view
            VStack {
                navigation
                    .padding(.top, style.contentPadding.top)
                    .padding(.leading, style.contentPadding.leading)
                    .padding(.trailing, style.contentPadding.trailing)
                    .padding(.bottom, 8)

                content
            }
            .applyBackground(style.background)
            .applyCornerRadii(
                size: style.cornerRadius,
                from: themeObserver.theme
            )
        }
        .frame(maxWidth: .infinity, maxHeight: 254)
        .padding(style.padding)
        .onAppear {
            contentObserver.startObservingCardChangeNotifications()
        }
        .onDisappear {
            contentObserver.stopObservingCardChangeNotifications()
        }
        .onChange(of: contentObserver.currentCard) { _, _ in
        }
    }

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

    @ViewBuilder var content: some View {
        GeometryReader { geometry in

            ScrollView(.horizontal) {
                LazyHStack {
                    ForEach(
                        contentObserver.cards.indices,
                        id: \.self
                    ) { index in
                        let card = contentObserver.cards[index]

                        ZStack {
                            Rectangle()
                                .fill(
                                    Color(
                                        hue: Double(index) / 10,
                                        saturation: 1,
                                        brightness: 1
                                    )
                                    .gradient
                                )

                            Text(card.id)
                        }
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                    }
                    .listStyle(.plain)
                }
                .scrollTargetLayout()
            }
            .scrollIndicators(.never)
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(true)
            .background(.green)
        }
    }
}

#Preview {
    VStack {
        ParraContainerPreview { componentFactory in
            FeedbackCardWidget(
                componentFactory: componentFactory,
                contentObserver: FeedbackCardWidget.ContentObserver(
                    notificationCenter: ParraNotificationCenter(),
                    syncHandler: nil
                ),
                config: .default,
                style: .default(with: componentFactory.theme)
            )
        }
    }
    .padding()
    .background(ParraTheme.default.palette.secondaryBackground)
}
