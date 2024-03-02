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
        localFactory: FeedbackCardWidgetFactory? = nil,
        theme: ParraTheme = .default
    ) {
        self.content = content
        self.cards = cards
        self.config = config
        self.options = [.theme(theme)]
        self.factory = ComponentFactory<FeedbackCardWidgetFactory>(
            local: localFactory,
            global: GlobalComponentAttributes(),
            theme: theme
        )
    }

    // MARK: - Internal

    var body: some View {
        ParraAppView(
            authProvider: .preview,
            options: options,
            appDelegateType: ParraAppDelegate.self,
            launchScreenConfig: .preview,
            sceneContent: { parra in
                GeometryReader { geometry in
                    ZStack {
                        Rectangle()
                            .ignoresSafeArea()
                            .foregroundStyle(
                                ParraTheme.default.palette.secondaryBackground
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
                        cards: cards,
                        notificationCenter: parra.notificationCenter,
                        dataManager: parra.feedback.dataManager,
                        syncHandler: nil
                    )
                )
            }
        )
        .environmentObject(factory)
        .environment(config)
    }

    // MARK: - Private

    @ViewBuilder private var content: () -> Content

    private let cards: [ParraCardItem]
    private let config: FeedbackCardWidgetConfig
    private let factory: ComponentFactory<FeedbackCardWidgetFactory>
    private let options: [ParraConfigurationOption]
}