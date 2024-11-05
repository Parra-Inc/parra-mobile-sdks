//
//  ParraUserSettingsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

struct ParraUserSettingsView: View {
    // MARK: - Internal

    @State var layout: ParraUserSettingsLayout

    var body: some View {
        VStack {
            withContent(content: layout.description) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .subheadline
                        ),
                        background: parraTheme.palette.primaryBackground.toParraColor()
                    )
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .safeAreaPadding(.horizontal)
                .padding(.bottom, 16)
            }

            List {
                ForEach(
                    Array(layout.groups.enumerated()),
                    id: \.element
                ) { index, group in
                    UserSettingsGroupView(group: group) {
                        if index == layout.groups.count - 1 {
                            withContent(content: layout.footerLabel) { content in
                                componentFactory.buildLabel(
                                    text: content,
                                    localAttributes: .default(with: .footnote)
                                )
                            }
                        }
                    }
                    .id(group.id)
                }
            }
            .background(
                parraTheme.palette.primaryBackground.toParraColor()
            )
            .scrollContentBackground(.hidden)
        }
        .background(
            parraTheme.palette.primaryBackground.toParraColor()
        )
        .navigationTitle(layout.title)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}
