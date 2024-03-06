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
        factory localFactory: FeedbackCardWidgetFactory? = nil,
        cardDelegate: ParraCardViewDelegate? = nil
    ) {
        self.cards = cards
        self.config = config
        self.style = style
        self.localFactory = localFactory
        self.cardDelegate = cardDelegate
    }

    // MARK: - Public

    public var body: some View {
        let theme = parra.configuration.theme
        let globalComponentAttributes = parra.configuration
            .globalComponentAttributes
        let style = style ?? .default(with: theme)

        FeedbackCardWidget(
            config: config,
            style: style,
            componentFactory: ComponentFactory<Wrapped.Factory>(
                local: localFactory,
                global: globalComponentAttributes,
                theme: theme
            ),
            contentObserver: Wrapped.ContentObserver(
                initialParams: .init(
                    cards: cards,
                    notificationCenter: parra.notificationCenter,
                    dataManager: parra.feedback.dataManager,
                    cardDelegate: cardDelegate,
                    syncHandler: {
                        Task {
                            await parra.triggerSync()
                        }
                    }
                )
            )
        )
    }

    // MARK: - Internal

    typealias Wrapped = FeedbackCardWidget

    @Environment(Parra.self) var parra
    @EnvironmentObject var themeObserver: ParraThemeObserver

    // MARK: - Private

    private let cards: [ParraCardItem]
    private let config: Wrapped.Config
    private let style: Wrapped.Style?
    private let localFactory: Wrapped.Factory?
    private weak var cardDelegate: ParraCardViewDelegate?
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(ParraTheme.default.palette.secondaryBackground)
                .frame(width: geometry.size.width, height: geometry.size.height)

            ParraViewPreview {
                ParraFeedbackView(cards: ParraCardItem.validStates())
            }
            .padding()
        }
    }
}
