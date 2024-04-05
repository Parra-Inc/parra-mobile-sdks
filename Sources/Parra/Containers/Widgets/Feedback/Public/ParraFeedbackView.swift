//
//  ParraFeedbackView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraFeedbackView: ParraPublicContainer {
    // MARK: - Lifecycle

    public init(
        cards: [ParraCardItem],
        config: FeedbackCardWidgetConfig = .default,
        style: FeedbackCardWidgetStyle? = nil,
        localbuilderConfig: FeedbackCardWidgetBuilderConfig = .init(),
        cardDelegate: ParraCardViewDelegate? = nil
    ) {
        self.cards = cards
        self.config = config
        self.style = style
        self.localbuilderConfig = localbuilderConfig
        self.cardDelegate = cardDelegate
    }

    // MARK: - Public

    public var body: some View {
        let parraInstance = parra.parraInternal!

        let theme = parraInstance.configuration.theme
        let globalComponentAttributes = parraInstance.configuration
            .globalComponentAttributes
        let style = style ?? .default(with: theme)

        FeedbackCardWidget(
            config: config,
            style: style,
            localBuilderConfig: localbuilderConfig,
            componentFactory: ComponentFactory(
                global: globalComponentAttributes,
                theme: theme
            ),
            contentObserver: Wrapped.ContentObserver(
                initialParams: .init(
                    cards: cards,
                    notificationCenter: parraInstance.notificationCenter,
                    dataManager: parraInstance.feedback.dataManager,
                    cardDelegate: cardDelegate,
                    syncHandler: {
                        Task {
                            await parraInstance.triggerSync()
                        }
                    }
                )
            )
        )
    }

    // MARK: - Internal

    typealias Wrapped = FeedbackCardWidget

    @Environment(\.parra) var parra
    @EnvironmentObject var themeObserver: ParraThemeObserver

    // MARK: - Private

    private let cards: [ParraCardItem]
    private let config: Wrapped.Config
    private let style: Wrapped.Style?
    private let localbuilderConfig: Wrapped.BuilderConfig
    private weak var cardDelegate: ParraCardViewDelegate?
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(ParraTheme.default.palette.secondaryBackground)
                .frame(width: geometry.size.width, height: geometry.size.height)

            ParraViewPreview { _ in
                ParraFeedbackView(cards: ParraCardItem.validStates())
            }
            .padding()
        }
    }
}
