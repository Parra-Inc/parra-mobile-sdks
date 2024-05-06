//
//  TextButton+RenderStorybook.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

// TODO: Rewrite this using normal factories

import SwiftUI

func renderStorybook(
    for componentType: (some TextButtonComponentType).Type
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

        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                renderColumn(for: componentType, size: .small)
                    .frame(width: 110)

                Divider()

                renderColumn(for: componentType, size: .medium)
                    .frame(width: 150)

                Divider()

                renderColumn(for: componentType, size: .large)
                    .frame(width: 200)
            }
        }
    }
    .padding(4)
}

private func renderButtonComponent(
    type: (some TextButtonComponentType).Type,
    config: TextButtonConfig,
    content: TextButtonContent,
    theme: ParraTheme = .default
) -> some View {
    return Text("TODO: Implement renderButtonComponent")
//    return type.init(
//        config: config,
//        content: content,
//        style: ParraAttributedTextButtonStyle(
//            config: config,
//            content: content,
//            attributes: type.applyStandardCustomizations(
//                onto: TextButtonAttributes(),
//                theme: theme,
//                config: config,
//                for: type
//            ),
//            theme: theme
//        ),
//        onPress: {}
//    )
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
    for componentType: (some TextButtonComponentType).Type,
    size: ParraButtonSize
) -> some View {
    let title = switch size {
    case .small:
        "Small"
    case .medium:
        "Medium"
    case .large:
        "Large"
    }

    return ScrollView {
        VStack(spacing: 24) {
            Group {
                renderRowTitle("Normal")

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title)
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title)
                    )
                )
            }

            Group {
                renderRowTitle("Normal w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(
                            text: title,
                            icon: .symbol("fireworks")
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(
                            text: title,
                            icon: .symbol("surfboard.fill")
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Max Width")

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .primary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title)
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .secondary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title)
                    )
                )
            }

            Group {
                renderRowTitle("Disabled")

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(text: title),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Disabled w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(
                            text: title,
                            icon: .symbol("fireworks")
                        ),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: TextButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: TextButtonContent(
                        text: LabelContent(
                            text: title,
                            icon: .symbol("fireworks")
                        ),
                        isDisabled: true
                    )
                )
            }
        }
    }
    .scrollIndicators(.never)
}
