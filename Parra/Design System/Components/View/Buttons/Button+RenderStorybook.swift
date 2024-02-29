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
                onto: ButtonAttributes(),
                theme: theme,
                config: config,
                for: type
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

    return ScrollView {
        VStack(spacing: 24) {
            Group {
                renderRowTitle("Image only")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .image(
                            .symbol("laser.burst")
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .image(
                            .symbol(
                                "lightspectrum.horizontal",
                                .multicolor
                            )
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Normal")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Normal w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(
                                text: title,
                                icon: UIImage(
                                    systemName: "fireworks"
                                )
                            )
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(
                                text: title,
                                icon: UIImage(
                                    systemName: "surfboard.fill"
                                )
                            )
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Max Width")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        )
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size,
                        isMaxWidth: true
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Disabled")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        ),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(text: title)
                        ),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Disabled w/icon")

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .primary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(
                                text: title,
                                icon: UIImage(
                                    systemName: "fireworks"
                                )
                            )
                        ),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    type: componentType,
                    config: ButtonConfig(
                        style: .secondary,
                        size: size
                    ),
                    content: ButtonContent(
                        type: .text(
                            LabelContent(
                                text: title,
                                icon: UIImage(
                                    systemName: "fireworks"
                                )
                            )
                        ),
                        isDisabled: true
                    )
                )
            }
        }
    }
    .scrollIndicators(.never)
}
