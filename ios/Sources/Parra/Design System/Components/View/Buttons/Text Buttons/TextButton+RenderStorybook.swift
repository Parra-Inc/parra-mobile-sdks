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
    for componentType: (some View).Type
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
    type: (some View).Type,
    config: ParraTextButtonConfig,
    content: ParraTextButtonContent,
    theme: ParraTheme = .default
) -> some View {
    return Text("TODO: Implement renderButtonComponent")
//    return type.init(
//        config: config,
//        content: content,
//        type: ParraAttributedTextButtonStyle(
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
    for componentType: (some View).Type,
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
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title)
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title)
                    )
                )
            }

            Group {
                renderRowTitle("Normal w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(
                            text: title,
                            icon: .symbol("fireworks")
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(
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
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title)
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title)
                    )
                )
            }

            Group {
                renderRowTitle("Disabled")

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(text: title),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Disabled w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(
                            text: title,
                            icon: .symbol("fireworks")
                        ),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ParraTextButtonConfig(
                        type: .secondary,
                        size: size
                    ),
                    content: ParraTextButtonContent(
                        text: ParraLabelContent(
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
