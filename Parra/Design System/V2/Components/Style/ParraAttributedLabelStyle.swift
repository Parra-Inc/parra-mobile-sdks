//
//  ParraAttributedLabelStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 2/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraAttributedLabelStyle: LabelStyle, ParraAttributedStyle {
    let config: LabelConfig
    let content: LabelContent
    let attributes: LabelAttributes
    let theme: ParraTheme

//    // TODO:
//        2. label/button attributes need consistent nullability when creating component instances

    func makeBody(configuration: Configuration) -> some View {
        let fontColor = attributes.fontColor ?? theme.palette.primaryText.toParraColor()

        HStack {
            Text(content.text)
                .frame(
                    minWidth: attributes.frame?.minWidth,
                    idealWidth: attributes.frame?.idealWidth,
                    maxWidth: attributes.frame?.maxWidth,
                    minHeight: attributes.frame?.minHeight,
                    idealHeight: attributes.frame?.idealHeight,
                    maxHeight: attributes.frame?.maxHeight,
                    alignment: attributes.frame?.alignment ?? .center
                )
                .foregroundStyle(fontColor)
                .padding(attributes.padding ?? .zero)
                .overlay(
                    UnevenRoundedRectangle(
                        cornerRadii: attributes.cornerRadius ?? .zero
                    )
                    .stroke(
                        fontColor,
                        lineWidth: attributes.borderWidth ?? 0
                    )
                )
                .applyBackground(attributes.background)
                .applyCornerRadii(attributes.cornerRadius)
                .font(attributes.font)
                .fontDesign(attributes.fontDesign)
                .fontWeight(attributes.fontWeight)
                .fontWidth(attributes.fontWidth)
        }
    }
}
