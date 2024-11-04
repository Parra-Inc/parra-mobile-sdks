//
//  ParraUserSettingsView.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import SwiftUI

struct ParraUserSettingsView: View, Equatable {
    // MARK: - Internal

    @State var layout: ParraUserSettingsLayout

    var body: some View {
        VStack {
            withContent(content: layout.description) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: .default(with: .subheadline)
                )
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .safeAreaPadding(.horizontal)
                .padding(.bottom, 16)
            }

            Form {
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
            .formStyle(.grouped)
        }
        .background(
            parraTheme.palette.secondaryBackground.toParraColor()
        )
        .navigationTitle(layout.title)
    }

    static func == (
        lhs: ParraUserSettingsView,
        rhs: ParraUserSettingsView
    ) -> Bool {
        return true
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { _ in
        NavigationStack {
            ParraUserSettingsView(
                layout: .validStates()[0]
            )
        }
    }
}
