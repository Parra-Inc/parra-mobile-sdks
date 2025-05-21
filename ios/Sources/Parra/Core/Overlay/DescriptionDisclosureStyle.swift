//
//  DescriptionDisclosureStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 5/19/25.
//

import SwiftUI

struct DescriptionDisclosureStyle: DisclosureGroupStyle {
    // MARK: - Internal

    func makeBody(configuration: Configuration) -> some View {
        VStack {
            if configuration.isExpanded {
                configuration.content.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
            } else {
                configuration.content.frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .lineLimit(4)
            }

            Button {
                withAnimation {
                    configuration.isExpanded.toggle()
                }
            } label: {
                VStack {
                    configuration.label

                    Image(
                        systemName: configuration
                            .isExpanded ? "chevron.up" : "chevron.down"
                    )
                    .fontWeight(.semibold)
                    .foregroundColor(
                        theme.palette.secondaryChipBackground.toParraColor()
                    )
                    .padding(.top, 8)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
