//
//  FeedbackCardWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 2/21/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackCardWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraFeedbackCardWidgetConfig,
        contentObserver: ContentObserver
    ) {
        self.config = config

        _contentObserver = StateObject(
            wrappedValue: contentObserver
        )
    }

    // MARK: - Internal

    static let height: CGFloat = 260

    @StateObject var contentObserver: ContentObserver
    let config: ParraFeedbackCardWidgetConfig

    @Environment(\.parraComponentFactory) var componentFactory
    @Environment(\.parra) var parra

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        ScrollViewReader { scrollViewProxy in
            VStack(spacing: 0) {
                // Extra wrapper used to support configuration of padding inside and
                // outside of the content view
                VStack(spacing: 10) {
                    navigation
                        .padding(.horizontal, from: contentPadding)

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
                .padding(.vertical, from: contentPadding)
                .applyBackground(defaultWidgetAttributes.background)
                .applyCornerRadii(
                    size: defaultWidgetAttributes.cornerRadius,
                    from: parraTheme
                )
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: FeedbackCardWidget.height
            )
        }
        .onAppear {
            contentObserver.startObservingCardChangeNotifications()
        }
        .onDisappear {
            contentObserver.stopObservingCardChangeNotifications()
        }
        .environment(config)
        .environment(componentFactory)
        .environmentObject(contentObserver)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    @ViewBuilder private var content: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: parraTheme
        )

        let contentPadding = parraTheme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        GeometryReader { geometry in
            ScrollView(.horizontal) {
                LazyHStack(alignment: .top, spacing: 0) {
                    ForEach(
                        contentObserver.cards.indices,
                        id: \.self
                    ) { index in
                        FeedbackCardView(
                            cardItem: contentObserver.cards[index],
                            contentPadding: contentPadding
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

            ParraContainerPreview<FeedbackCardWidget>(
                config: .default
            ) { parra, _, config in
                FeedbackCardWidget(
                    config: config,
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
