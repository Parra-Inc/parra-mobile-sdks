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
    config: ParraImageButtonConfig,
    content: ParraImageButtonContent,
    theme: ParraTheme = .default
) -> some View {
    EmptyView()
//    return ImageButtonComponent(
//        config: config,
//        content: content,
//        style: ParraAttributedImageButtonStyle(
//            config: config,
//            content: content,
//            attributes: ImageButtonComponent.applyStandardCustomizations(
//                onto: ImageButtonAttributes(image: ImageAttributes()),
//                theme: theme,
//                config: config
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
    size: ParraImageButtonSize
) -> some View {
    return ScrollView {
        VStack(spacing: 24) {
            Group {
                renderRowTitle("Plain")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.plain
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.plain
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Plain disabled")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.plain
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.plain
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
                            "lightspectrum.horizontal"
                        ),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Outlined")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.outlined
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.outlined
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Outlined disabled")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.outlined
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.outlined
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
                            "lightspectrum.horizontal"
                        ),
                        isDisabled: true
                    )
                )
            }

            Group {
                renderRowTitle("Contained")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.contained
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst")
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.contained
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
                            "lightspectrum.horizontal"
                        )
                    )
                )
            }

            Group {
                renderRowTitle("Contained disabled")

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.primary,
                        size: size,
                        variant: ParraButtonVariant.contained
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol("laser.burst"),
                        isDisabled: true
                    )
                )

                renderButtonComponent(
                    config: ParraImageButtonConfig(
                        type: ParraButtonType.secondary,
                        size: size,
                        variant: ParraButtonVariant.contained
                    ),
                    content: ParraImageButtonContent(
                        image: ParraImageContent.symbol(
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
