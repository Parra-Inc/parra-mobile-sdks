//
//  ParraCardViewPreview.swift
//  Parra
//
//  Created by Mick MacCallum on 2/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

@MainActor
struct ParraCardViewPreview<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        content: @escaping () -> Content,
        cards: [ParraCardItem] = ParraCardItem.validStates(),
        config: FeedbackCardWidgetConfig = .default,
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.cards = cards
        self.config = config
        self.configuration = ParraConfiguration(
            themeOptions: theme
        )
        self.factory = ComponentFactory(
            attributes: ParraGlobalComponentAttributes.default,
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        ParraAppView(
            target: .preview,
            configuration: configuration,
            viewContent: { parra in
                ParraOptionalAuthView { _ in
                    GeometryReader { geometry in
                        ZStack {
                            Rectangle()
                                .ignoresSafeArea()
                                .foregroundStyle(
                                    ParraTheme.default.palette
                                        .secondaryBackground
                                )
                                .frame(
                                    width: geometry.size.width,
                                    height: geometry.size.height
                                )

                            VStack {
                                Spacer()

                                content()
                                    .padding()

                                Spacer()
                            }
                        }
                    }
                    .environmentObject(
                        FeedbackCardWidget.ContentObserver(
                            initialParams: .init(
                                cards: cards,
                                notificationCenter: parra.parraInternal
                                    .notificationCenter,
                                dataManager: parra.parraInternal.feedback
                                    .dataManager,
                                syncHandler: nil
                            )
                        )
                    )
                }
            }
        )
        .environmentObject(factory)
        .environment(config)
    }

    // MARK: - Private

    @ViewBuilder private var content: () -> Content

    private let cards: [ParraCardItem]
    private let config: FeedbackCardWidgetConfig
    private let factory: ComponentFactory
    private let configuration: ParraConfiguration
}
