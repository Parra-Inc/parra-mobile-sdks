//
//  FAQWidget.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

struct FAQWidget: ParraContainer {
    // MARK: - Lifecycle

    init(
        config: ParraFAQConfiguration,
        contentObserver: ContentObserver,
        navigationPath: Binding<NavigationPath>
    ) {
        self.config = config
        self._contentObserver = State(wrappedValue: contentObserver)
    }

    // MARK: - Internal

    @State var contentObserver: ContentObserver
    let config: ParraFAQConfiguration

    @ViewBuilder
    @MainActor var body: some View {
        switch contentObserver.loadState {
        case .initial, .loading:
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity
            )
            .background(
                parraTheme.palette.secondaryBackground.toParraColor()
            )
            .task { @MainActor in
                if contentObserver.loadState == .initial {
                    await contentObserver.loadFaqs()
                }
            }
        case .loaded(let layout):
            ParraFAQView(
                layout: layout,
                config: config
            )
        case .error:
            componentFactory.buildEmptyState(
                config: .errorDefault,
                content: config.errorStateContent
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(\.parraComponentFactory) private var componentFactory
}

#Preview {
    ParraContainerPreview<FAQWidget>(config: .default) { parra, _, config in
        FAQWidget(
            config: config,
            contentObserver: .init(
                initialParams: FAQWidget.ContentObserver.InitialParams(
                    layout: ParraAppFaqLayout.validStates()[0],
                    config: config,
                    api: parra.parraInternal.api
                )
            ),
            navigationPath: .constant(.init())
        )
    }
}
