//
//  YouTubeDescriptionDisclosureStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/25.
//

import SwiftUI

struct YouTubeDescriptionDisclosureStyle: DisclosureGroupStyle {
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
                HStack {
                    configuration.label

                    Spacer()

                    Text(configuration.isExpanded ? "show less" : "... more")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
                .contentShape(.rect)
            }
            .buttonStyle(.plain)
        }
    }
}
