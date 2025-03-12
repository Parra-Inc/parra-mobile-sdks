//
//  CreatorUpdateVisibilitySettingView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/25.
//

import SwiftUI

struct CreatorUpdateVisibilitySettingView: View {
    // MARK: - Internal

    @Binding var currentVisibility: CreatorUpdateVisibilityType
    var title: String

    var body: some View {
        HStack {
            componentFactory.buildLabel(
                text: title,
                localAttributes: .default(with: .callout)
            )

            Spacer()

            Picker(
                title,
                selection: $currentVisibility
            ) {
                ForEach(CreatorUpdateVisibilityType.allCases) { type in
                    Text(type.composerName)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
