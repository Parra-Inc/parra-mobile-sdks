//
//  TextComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 1/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct TextComponent: View, Component {
    typealias Config = TextConfig
    typealias Content = TextContent
    typealias Style = TextStyle

    var config: Config
    var content: Content
    var style: Style

    static func defaultStyleInContext(
        of theme: ParraTheme,
        with config: Config
    ) -> Style {
        return .init()
    }

    var body: some View {
        Text(content.text)
            .frame(
                minWidth: style.frame?.minWidth,
                idealWidth: style.frame?.idealWidth,
                maxWidth: style.frame?.maxWidth,
                minHeight: style.frame?.minHeight,
                idealHeight: style.frame?.idealHeight,
                maxHeight: style.frame?.maxHeight,
                alignment: style.frame?.alignment ?? .center
            )
            .foregroundStyle(style.fontColor ?? .black)
            .padding(style.padding ?? .zero)
            .overlay(
                UnevenRoundedRectangle(cornerRadii: style.cornerRadius ?? .zero)
                    .stroke(style.fontColor ?? .black, lineWidth: style.borderWidth ?? 0)
            )
            .applyBackground(style.background)
            .applyCornerRadii(style.cornerRadius)
            .font(style.font)
            .fontDesign(style.fontDesign)
            .fontWeight(style.fontWeight)
            .fontWidth(style.fontWidth)
    }
}

#Preview {
    return VStack(alignment: .leading, spacing: 15) {
        TextComponent(
            config: .init(),
            content: .init(text: "Default config"),
            style: .init()
        )

        TextComponent(
            config: .init(),
            content: .init(text: "A large title"),
            style: .init(
                font: .largeTitle.bold(),
                fontColor: Color.black
            )
        )

        TextComponent(
            config: .init(),
            content: .init(text: "A subheadline"),
            style: .init(
                font: .subheadline,
                fontColor: Color.gray
            )
        )

        TextComponent(
            config: .init(),
            content: .init(text: "With a background"),
            style: .init(
                background: .red,
                font: .title,
                fontColor: Color.green
            )
        )

        TextComponent(
            config: .init(),
            content: .init(text: "With a gradient background"),
            style: .init(
                background: Gradient(colors: [.pink, .purple]),
                cornerRadius: .init(allCorners: 4),
                font: .title,
                fontColor: Color.white,
                padding: .init(top: 4, leading: 10, bottom: 4, trailing: 10)
            )
        )

        TextComponent(
            config: .init(),
            content: .init(text: "With a corner radius"),
            style: .init(
                background: .green,
                cornerRadius: .init(allCorners: 12),
                font: .subheadline,
                fontColor: Color.gray,
                padding: .init(top: 6, leading: 6, bottom: 6, trailing: 6)
            )
        )
   }
}
