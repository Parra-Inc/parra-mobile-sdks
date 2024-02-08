//
//  Button+RenderStorybook.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

func renderStorybook(
    for componentType: (some ButtonComponentType).Type
) -> some View {
    return VStack {
        HStack {
            Spacer()
            Text("Small")
                .font(.title3)
            Spacer()
            Spacer()

            Text("Medium")
                .font(.title3)
            Spacer()
            Spacer()
            Text("Large")
                .font(.title3)
            Spacer()
        }

        Divider()

        HStack(alignment: .top) {
            renderColumn(for: componentType, size: .small)
                .frame(width: 70)

            Divider()

            renderColumn(for: componentType, size: .medium)
                .frame(width: 100)

            Divider()

            renderColumn(for: componentType, size: .large)
        }
    }
    .padding()
}

private func renderButtonComponent(
    type: (some ButtonComponentType).Type,
    config: ButtonConfig,
    content: ButtonContent,
    theme: ParraTheme = .default
) -> some View {
    return type.init(
        config: config,
        content: content,
        style: ParraAttributedButtonStyle(
            config: config,
            content: content,
            attributes: type.applyStandardCustomizations(
                onto: .init(),
                theme: theme,
                config: config
            ),
            theme: theme
        )
    )
}

private func renderRowTitle(_ title: String) -> some View {
    VStack {
        Text(title)
            .font(.caption)

        Divider()
    }
    .padding(.top)
}

private func renderColumn(
    for componentType: (some ButtonComponentType).Type,
    size: ButtonSize
) -> some View {
    let title = switch size {
    case .small:
        "Small"
    case .medium:
        "Medium"
    case .large:
        "Large"
    }

    return VStack(spacing: 24) {
        Group {
            renderRowTitle("Normal")

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .primary,
                    size: size
                ),
                content: .init(title: .init(text: title))
            )

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .secondary,
                    size: size
                ),
                content: .init(title: .init(text: title))
            )
        }

        Group {
            renderRowTitle("Max Width")

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .primary,
                    size: size,
                    isMaxWidth: true
                ),
                content: .init(title: .init(text: title))
            )

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .secondary,
                    size: size,
                    isMaxWidth: true
                ),
                content: .init(title: .init(text: title))
            )
        }

        Group {
            renderRowTitle("Disabled")

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .primary,
                    size: size
                ),
                content: .init(title: .init(text: title), isDisabled: true)
            )

            renderButtonComponent(
                type: componentType,
                config: .init(
                    style: .secondary,
                    size: size
                ),
                content: .init(title: .init(text: title), isDisabled: true)
            )
        }
    }
}
