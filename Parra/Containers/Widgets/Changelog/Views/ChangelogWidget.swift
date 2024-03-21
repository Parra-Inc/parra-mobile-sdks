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
        style: ChangelogWidgetStyle,
        localBuilderConfig: ChangelogWidgetBuilderConfig,
        componentFactory: ComponentFactory,
        contentObserver: ContentObserver
    ) {
        self.config = config
        self.style = style
        self.localBuilderConfig = localBuilderConfig
        self.componentFactory = componentFactory
        self._contentObserver = StateObject(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    let localBuilderConfig: ChangelogWidgetBuilderConfig
    let componentFactory: ComponentFactory
    @StateObject var contentObserver: ContentObserver
    let config: ChangelogWidgetConfig
    let style: ChangelogWidgetStyle

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var headerSpace: CGFloat {
        return style.contentPadding.top
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading) {
                    componentFactory.buildLabel(
                        config: config.title,
                        content: contentObserver.content.title,
                        suppliedBuilder: localBuilderConfig.title
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding([.horizontal, .top], from: style.contentPadding)
                .padding(.bottom, headerSpace)
                .border(
                    width: 1,
                    edges: .bottom,
                    color: showNavigationDivider
                        ? themeObserver.theme.palette
                        .secondaryBackground : .clear
                )

                list
                    .navigationDestination(
                        for: AppReleaseStubContent.self
                    ) { release in
                        AppReleaseDetailView(
                            contentObserver: AppReleaseContentObserver(
                                standalone: false,
                                stub: release.originalStub,
                                networkManager: contentObserver.networkManager
                            ),
                            style: style
                        )
                        .environment(config)
                        .environment(localBuilderConfig)
                        .environmentObject(contentObserver)
                    }
            }
        }
        .padding(style.padding)
        .applyBackground(style.background)
        .environment(config)
        .environment(localBuilderConfig)
        .environmentObject(contentObserver)
        .environmentObject(componentFactory)
    }

    var items: some View {
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
                            content: release,
                            style: style
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
                .padding(style.contentPadding)
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

    var list: some View {
        ScrollView {
            items
        }
        // A limited number of placeholder cells will be generated.
        // Don't allow scrolling past them while loading.
        .scrollDisabled(
            contentObserver.releasePaginator.isShowingPlaceholders
        )
        .contentMargins(
            .top,
            headerSpace,
            for: .scrollContent
        )
        .contentMargins(
            [.leading, .trailing, .bottom],
            style.contentPadding,
            for: .scrollContent
        )
        .emptyPlaceholder(contentObserver.releasePaginator.items) {
            componentFactory.buildEmptyState(
                config: config.emptyStateView,
                content: contentObserver.content.emptyStateView,
                suppliedBuilder: localBuilderConfig.emptyStateView,
                localAttributes: style.emptyState
            )
        }
        .errorPlaceholder(contentObserver.releasePaginator.error) {
            componentFactory.buildEmptyState(
                config: config.errorStateView,
                content: contentObserver.content.errorStateView,
                suppliedBuilder: localBuilderConfig.errorStateView,
                localAttributes: style.errorState
            )
        }
        .refreshable {
            await contentObserver.releasePaginator.refresh()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .coordinateSpace(name: "scroll")
    }

    // MARK: - Private

    @State private var showNavigationDivider = false
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { parra, componentFactory, _, builderConfig in
        ChangelogWidget(
            config: .default,
            style: .default(with: .default),
            localBuilderConfig: builderConfig,
            componentFactory: componentFactory,
            contentObserver: .init(
                initialParams: .init(
                    appReleaseCollection: AppReleaseCollectionResponse
                        .validStates()[0],
                    networkManager: parra.networkManager
                )
            )
        )
    }
}
