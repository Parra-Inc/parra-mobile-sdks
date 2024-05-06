//
//  FeedbackCardWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackCardWidget: Container {
    // MARK: - Lifecycle

    init(
        config: FeedbackCardWidgetConfig,
        style: FeedbackCardWidgetStyle,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.componentFactory = componentFactory
        self.config = config
        self.style = style

        _contentObserver = StateObject(
            wrappedValue: contentObserver
        )
    }

    // MARK: - Internal

    static let height: CGFloat = 260

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: FeedbackCardWidgetConfig
    let style: FeedbackCardWidgetStyle

    @Environment(\.parra) var parra
    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        ScrollViewReader { scrollViewProxy in
            VStack(spacing: 0) {
                // Extra wrapper used to support configuration of padding inside and
                // outside of the content view
                VStack(spacing: 10) {
                    navigation
                        .padding(.horizontal, from: style.contentPadding)

                    // Leading and trailing content padding isn't applied to cards
                    // it will be grabbed later and applied to their content to keep
                    // the cards full width.
                    content
                        .onChange(
                            of: contentObserver
                                .currentCardInfo
                        ) { _, newValue in
                            if let newValue {
                                withAnimation {
                                    scrollViewProxy.scrollTo(
                                        newValue.index,
                                        anchor: .center
                                    )
                                }
                            }
                        }
                }
                .clipped()
                .padding(.vertical, from: style.contentPadding)
                .applyBackground(style.background)
                .applyCornerRadii(
                    size: style.cornerRadius,
                    from: themeObserver.theme
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: FeedbackCardWidget.height
            )
            .padding(style.padding)
        }
        .onAppear {
            contentObserver.startObservingCardChangeNotifications()
        }
        .onDisappear {
            contentObserver.stopObservingCardChangeNotifications()
        }
        .environment(config)
        .environmentObject(componentFactory)
        .environmentObject(contentObserver)
    }

    // MARK: - Private

    @ViewBuilder private var content: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(
                        contentObserver.cards.indices,
                        id: \.self
                    ) { index in
                        FeedbackCardView(
                            cardItem: contentObserver.cards[index],
                            contentPadding: style.contentPadding
                        )
                        .frame(
                            width: geometry.size.width,
                            height: geometry.size.height
                        )
                        .id(index)
                    }
                    .listStyle(.plain)
                }
            }
            .scrollIndicators(.never)
            .scrollTargetBehavior(.paging)
            .scrollDisabled(true)
        }
    }
}

#Preview {
    GeometryReader { geometry in
        ZStack {
            Rectangle()
                .ignoresSafeArea()
                .foregroundStyle(ParraTheme.default.palette.secondaryBackground)
                .frame(width: geometry.size.width, height: geometry.size.height)

            ParraContainerPreview<FeedbackCardWidget> { parra, componentFactory, _ in
                FeedbackCardWidget(
                    config: .default,
                    style: .default(with: componentFactory.theme),
                    componentFactory: componentFactory,
                    contentObserver: .init(
                        initialParams: .init(
                            cards: ParraCardItem.validStates(),
                            notificationCenter: ParraNotificationCenter.default,
                            dataManager: parra.parraInternal.feedback
                                .dataManager,
                            syncHandler: nil
                        )
                    )
                )
            }
            .padding()
        }
    }
}
