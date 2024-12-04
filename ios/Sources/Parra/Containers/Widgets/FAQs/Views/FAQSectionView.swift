//
//  FAQSectionView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import SwiftUI

struct FAQSectionView: View {
    // MARK: - Internal

    let section: ParraAppFaqSection

    var body: some View {
        VStack(spacing: 16) {
            withContent(content: section.title) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: ParraAttributes.Label(
                        text: .default(with: .title),
                        background: theme.palette.primaryBackground.toParraColor()
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            }

            VStack(spacing: 6) {
                ForEach(section.items) { item in
                    FAQItemView(faq: item)
                }
            }
        }
        .padding(.vertical, 12)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
