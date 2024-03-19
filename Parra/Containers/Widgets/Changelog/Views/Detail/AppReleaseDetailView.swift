//
//  AppReleaseDetailView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseDetailView: View {
    /// Is being used on its own, aka the "What's New" view.
    var standalone: Bool

    @StateObject var contentObserver: AppReleaseContentObserver

    let style: ChangelogWidgetStyle

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    var sections: some View {
        LazyVStack(alignment: .leading, spacing: 24) {
            ForEach(contentObserver.content.sections) { section in
                ChangelogSectionView(content: section)
            }
            .disabled(contentObserver.isLoading)
        }
        .padding(.top, 6)
        .redacted(
            when: contentObserver.isLoading
        )
    }

    var header: some View {
        VStack(alignment: .leading, spacing: 12) {
            if standalone {
                componentFactory.buildLabel(
                    config: config.releaseDetailWhatsNew,
                    content: contentObserver.content.whatsNewTitle,
                    suppliedBuilder: builderConfig.releaseDetailWhatsNew
                )
            }

            componentFactory.buildLabel(
                config: config.releaseDetailTitle,
                content: contentObserver.content.name,
                suppliedBuilder: builderConfig.releaseDetailTitle
            )
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)

            ChangelogItemInfoView(
                content: contentObserver.content
            )
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20.0) {
                    header

                    withContent(
                        content: contentObserver.content
                            .description
                    ) { content in
                        componentFactory.buildLabel(
                            config: config.releaseDetailDescription,
                            content: content,
                            suppliedBuilder: builderConfig
                                .releaseDetailDescription
                        )
                    }

                    sections
                }
            }
            .contentMargins(
                .all,
                style.contentPadding,
                for: .scrollContent
            )

            WidgetFooter {}
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .applyBackground(style.background)
        .task {
            await contentObserver.loadSections()
        }
    }
}
