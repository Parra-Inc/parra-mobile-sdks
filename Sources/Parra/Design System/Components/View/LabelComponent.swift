//
//  LabelComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct LabelComponent: LabelComponentType {
    // MARK: - Lifecycle

    init(
        content: LabelContent,
        attributes: ParraAttributes.Label
    ) {
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Internal

    let content: LabelContent
    let attributes: ParraAttributes.Label

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        Label(
            title: {
                Text(content.text)
                    .applyTextAttributes(
                        attributes.text,
                        using: themeObserver.theme
                    )
            },
            icon: {
                if content.isLoading {
                    ProgressView()
                        .tint(attributes.text.color ?? .black)
                } else {
                    withContent(
                        content: content.icon
                    ) { content in
                        ImageComponent(
                            content: content,
                            attributes: attributes.icon
                        )
                        // Need to override resizable modifier from
                        // general implementation.
                        .fixedSize()
                    }
                }
            }
        )
        .applyLabelAttributes(
            attributes,
            using: themeObserver.theme
        )
        .contentShape(.rect)
    }
}

#Preview {
    ParraViewPreview { factory in
        VStack(alignment: .leading, spacing: 16) {
            factory.buildLabel(
                fontStyle: .body,
                content: LabelContent(text: "Default config")
            )

            factory.buildLabel(
                fontStyle: .title,
                content: LabelContent(text: "A large title")
            )

            factory.buildLabel(
                fontStyle: .subheadline,
                content: LabelContent(text: "A subheadline")
            )

            factory.buildLabel(
                fontStyle: .subheadline,
                content: LabelContent(
                    text: "A subheadline with icon",
                    icon: .symbol("sun.rain.circle.fill")
                )
            )

            factory.buildLabel(
                fontStyle: .body,
                content: LabelContent(text: "With a background")
            )
            .background(.red)
            .font(.title)
            .foregroundColor(.green)

            factory.buildLabel(
                fontStyle: .title,
                content: LabelContent(text: "With a gradient background")
            )
            .background(Gradient(colors: [.pink, .purple]))
            .cornerRadius(4)
            .padding(EdgeInsets(
                top: 4,
                leading: 10,
                bottom: 4,
                trailing: 10
            ))
            .foregroundStyle(.white)

            factory.buildLabel(
                fontStyle: .title,
                content: LabelContent(
                    text: "BG gradient and icon",
                    icon: .symbol("fireworks")
                )
            )
            .foregroundStyle(.white)
            .cornerRadius(4)
            .padding(EdgeInsets(
                top: 4,
                leading: 10,
                bottom: 4,
                trailing: 10
            ))
            .background(Gradient(colors: [.pink, .purple]))

            factory.buildLabel(
                fontStyle: .subheadline,
                content: LabelContent(text: "With a corner radius")
            )
            .cornerRadius(8)
            .background(.green)
            .padding(EdgeInsets(
                top: 8,
                leading: 8,
                bottom: 8,
                trailing: 8
            ))
        }
    }
}
