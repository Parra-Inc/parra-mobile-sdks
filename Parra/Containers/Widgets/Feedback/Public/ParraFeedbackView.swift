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

    init(
        config: Wrapped.Config = .default,
        style: Wrapped.Style? = nil,
        factory localFactory: Wrapped.Factory? = nil,
        cardDelegate: ParraCardViewDelegate? = nil
    ) {
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
            componentFactory: ComponentFactory<Wrapped.Factory>(
                local: localFactory,
                global: globalComponentAttributes,
                theme: theme
            ),
            contentObserver: Wrapped.ContentObserver(
                notificationCenter: parra.notificationCenter,
                syncHandler: {
                    Task {
                        await parra.triggerSync()
                    }
                }
            ),
            config: config,
            style: style,
            cardDelegate: cardDelegate
        )
    }

    // MARK: - Internal

    typealias Wrapped = FeedbackCardWidget

    @Environment(Parra.self) var parra
    @EnvironmentObject var themeObserver: ParraThemeObserver

    // MARK: - Private

    private let config: Wrapped.Config
    private let style: Wrapped.Style?
    private let localFactory: Wrapped.Factory?
    private weak var cardDelegate: ParraCardViewDelegate?
}
