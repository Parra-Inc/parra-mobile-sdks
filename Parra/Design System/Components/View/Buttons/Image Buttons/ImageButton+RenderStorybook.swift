//
//  ImageButton+RenderStorybook.swift
//  Parra
//
//  Created by Mick MacCallum on 3/4/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

func renderImageButtonStorybook() -> some View {
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
            Spacer()

            Text("Custom")
                .font(.title3)

            Spacer()
        }

        Divider()

        ScrollView(.horizontal) {
            HStack(alignment: .top) {
                renderColumn(size: .smallSquare)
                    .frame(width: 60)

                Divider()

                renderColumn(size: .mediumSquare)
                    .frame(width: 70)

                Divider()

                renderColumn(size: .largeSquare)
                    .frame(width: 100)

                Divider()

                renderColumn(size: .custom(CGSize(width: 80, height: 40)))
                    .frame(width: 120)
            }
        }
    }
    .padding(4)
}

private func renderButtonComponent(
    config: ImageButtonConfig,
    content: ImageButtonContent,
    theme: ParraTheme = .default
) -> some View {
    return ImageButtonComponent(
        config: config,
        content: content,
        style: ParraAttributedImageButtonStyle(
            config: config,
            content: content,
            attributes: ImageButtonComponent.applyStandardCustomizations(
                onto: ImageButtonAttributes(image: ImageAttributes()),
                theme: theme,
                config: config
            ),
            theme: theme
        ),
        onPress: {}
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
    size: ImageButtonConfig.Size
) -> some View {
    return ScrollView {
        VStack(spacing: 24) {
            Group {
                renderRowTitle("Plain")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .plain
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .plain
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Plain disabled")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .plain
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .plain
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        ),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Outlined")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .outlined
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .outlined
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Outlined disabled")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .outlined
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .outlined
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        ),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Contained")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .contained
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .contained
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Contained disabled")

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .primary,
                        size: size,
                        variant: .contained
                    ),
                    content: ImageButtonContent(
                        image: .symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ImageButtonConfig(
                        style: .secondary,
                        size: size,
                        variant: .contained
                    ),
                    content: ImageButtonContent(
                        image: .symbol(
                            "lightspectrum.horizontal"
                        ),
                        isDisabled: true
                    )
                )
            }
        }
    }
    .scrollIndicators(.never)
}
