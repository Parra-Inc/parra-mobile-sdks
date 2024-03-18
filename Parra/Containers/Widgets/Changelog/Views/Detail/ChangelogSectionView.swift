//
//  ChangelogSectionView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ChangelogItem: View {
    let content: TicketStubContent

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    var body: some View {
        HStack {
//            Text(content.ticketNumber)
            Text(content.title.text)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct ChangelogSectionView: View {
    let content: AppReleaseSectionContent

    @Environment(ChangelogWidgetConfig.self) var config
    @Environment(ChangelogWidgetBuilderConfig.self) var builderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    var body: some View {
        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                config: config.releaseDetailTitle,
                content: content.title,
                suppliedBuilder: builderConfig.releaseDetailSectionTitle
            )

            ForEach(content.items) { item in
                VStack {
                    ChangelogItem(content: item)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ParraContainerPreview<ChangelogWidget> { _, _, _, _ in
        ChangelogSectionView(
            content: AppReleaseSectionContent(
                AppReleaseSection.validStates()[0]
            )
        )
    }
}
