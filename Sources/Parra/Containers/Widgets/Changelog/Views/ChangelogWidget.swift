//
//  ChangelogWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 3/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChangelogWidget: Container {
    // MARK: - Lifecycle

    init(
        config: ChangelogWidgetConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ChangelogWidgetConfig

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        let defaultWidgetAttributes = ParraAttributes.Widget.default(
            with: themeObserver.theme
        )

        let contentPadding = themeObserver.theme.padding.value(
            for: defaultWidgetAttributes.contentPadding
        )

        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                componentFactory.buildLabel(
                    content: contentObserver.content.title,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            font: .title
                        ),
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )
            }
            .padding([.horizontal, .top], from: contentPadding)
            .padding(.bottom, headerSpace(with: contentPadding))
            .border(
                width: 1,
                edges: .bottom,
                color: showNavigationDivider
                    ? themeObserver.theme.palette
                    .secondaryBackground : .clear
            )

            list(with: defaultWidgetAttributes)
                .environment(config)
                .environmentObject(contentObserver)
                .environmentObject(componentFactory)
                .navigationDestination(
                    for: AppReleaseStubContent.self
                ) { release in
                    let contentObserver = ReleaseContentObserver(
                        initialParams: .init(
                            contentType: .stub(
                                release.originalStub
                            ),
                            api: contentObserver.api
                        )
                    )

                    ReleaseWidget(
                        config: config,
                        componentFactory: componentFactory,
                        contentObserver: contentObserver
                    )
                    .environmentObject(navigationState)
                }
        }
        .applyWidgetAttributes(
            attributes: defaultWidgetAttributes.withoutContentPadding(),
            using: themeObserver.theme
        )
        .applyPadding(
            size: defaultWidgetAttributes.padding,
            on: [.horizontal, .bottom],
            from: themeObserver.theme
        )
    }

    func headerSpace(
        with contentPadding: EdgeInsets
    ) -> CGFloat {
        return contentPadding.top
    }

    func items(
        with attributes: ParraAttributes.Widget
    ) -> some View {
        LazyVStack(alignment: .leading, spacing: 12) {
            let items = contentObserver.releasePaginator.items

            ForEach(
                Array(items.enumerated()),
                id: \.element
            ) { index, release in
                NavigationLink(
                    value: release,
                    label: {
                        ChangelogListItem(
                            content: release
                        )
                    }
                )
                .disabled(
                    contentObserver.releasePaginator
                        .isShowingPlaceholders
                )
                .onAppear {
                    contentObserver.releasePaginator
                        .loadMore(after: index)
                }
                .id(release.id)
            }

            if contentObserver.releasePaginator.isLoading {
                VStack(alignment: .center) {
                    ProgressView()
                }
                .frame(maxWidth: .infinity)
                .applyPadding(
                    size: attributes.contentPadding,
                    from: themeObserver.theme
                )
            }
        }
        .redacted(
            when: contentObserver.releasePaginator.isShowingPlaceholders
        )
        .background(GeometryReader {
            Color.clear.preference(
                key: ViewOffsetKey.self,
                value: -$0.frame(in: .named("scroll")).origin.y
            )
        })
        .onPreferenceChange(ViewOffsetKey.self) { offset in
            showNavigationDivider = offset > 0.0
        }
    }

    @ViewBuilder
    func list(
        with attributes: ParraAttributes.Widget
    ) -> some View {
        let contentPadding = themeObserver.theme.padding.value(
            for: attributes.contentPadding
        )

        ScrollView {
            items(with: attributes)
        }
        // A limited number of placeholder cells will be generated.
        // Don't allow scrolling past them while loading.
        .scrollDisabled(
            contentObserver.releasePaginator.isShowingPlaceholders
        )
        .contentMargins(
            .top,
            headerSpace(with: contentPadding),
            for: .scrollContent
        )
        .contentMargins(
            [.leading, .trailing, .bottom],
            contentPadding,
            for: .scrollContent
        )
        .emptyPlaceholder(contentObserver.releasePaginator.items) {
            componentFactory.buildEmptyState(
                config: EmptyStateConfig.default,
                content: contentObserver.content.emptyStateView
            )
        }
        .errorPlaceholder(contentObserver.releasePaginator.error) {
            componentFactory.buildEmptyState(
                config: EmptyStateConfig.errorDefault,
                content: contentObserver.content.errorStateView
            )
        }
        .refreshable {
            contentObserver.releasePaginator.refresh()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "scroll")
    }

    // MARK: - Private

    @EnvironmentObject private var navigationState: NavigationState

    @State private var showNavigationDivider = false
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { parra, componentFactory, _ in
        ChangelogWidget(
            config: .default,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: .init(
                    appReleaseCollection: AppReleaseCollectionResponse
                        .validStates()[0],
                    api: parra.parraInternal.api
                )
            )
        )
    }
}
