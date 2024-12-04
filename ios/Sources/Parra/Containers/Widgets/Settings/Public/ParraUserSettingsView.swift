//
//  ParraUserSettingsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

struct ParraUserSettingsView: View {
    // MARK: - Internal

    var layout: ParraUserSettingsLayout
    let onValueChanged: (_ key: String, _ value: ParraSettingsItemDataWithValue) -> Void

    var body: some View {
        List {
            ForEach(
                Array(layout.groups.enumerated()),
                id: \.element
            ) { index, group in
                UserSettingsGroupView(
                    group: group
                ) {
                    if index == layout.groups.count - 1 {
                        withContent(content: layout.footerLabel) { content in
                            componentFactory.buildLabel(
                                text: content,
                                localAttributes: .default(with: .footnote)
                            )
                        }
                    }
                } onValueChanged: { key, value in
                    onValueChanged(key, value)
                }
            }
        }
        .background(
            parraTheme.palette.primaryBackground.toParraColor()
        )
        .scrollContentBackground(.hidden)
        .navigationTitle(layout.title)
        .navigationBarTitleDisplayMode(.automatic)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}
