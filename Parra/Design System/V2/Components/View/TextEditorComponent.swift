//
//  TextEditorComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

internal struct TextEditorComponent: TextEditorComponentType {
    var config: TextEditorConfig
    var content: TextEditorContent
    var style: ParraAttributedTextEditorStyle

    @State private var text = ""
    @State private var hasReceivedInput = false

    @EnvironmentObject var themeObserver: ParraThemeObserver

    internal init(
        config: TextEditorConfig,
        content: TextEditorContent,
        style: ParraAttributedTextEditorStyle
    ) {
        self.config = config
        self.content = content
        self.style = style
    }

    static func applyStandardCustomizations(
        onto inputAttributes: TextEditorAttributes?,
        theme: ParraTheme,
        config: TextEditorConfig
    ) -> TextEditorAttributes {
        let palette = theme.palette

        return inputAttributes ?? TextEditorAttributes(
            cornerRadius: RectangleCornerRadii(allCorners: 8),
            font: .body,
            fontColor: palette.primaryText.toParraColor(),
            padding: .zero,
            frame: FrameAttributes(
                minHeight: 60,
                idealHeight: 100
            ),
            borderWidth: 1,
            borderColor: palette.secondaryText.toParraColor().opacity(0.6)
        )
    }

    @ViewBuilder
    func applyStyle(to view: some View) -> some View {
        let palette = themeObserver.theme.palette
        let attributes = style.attributes
        let fontColor = attributes.fontColor ?? palette.primaryText.toParraColor()

        view
            .contentMargins(
                .all,
                EdgeInsets(
                    top: 6,
                    leading: 8,
                    bottom: 6, 
                    trailing: 8
                ),
                for: .automatic
            )
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
                    attributes.borderColor ?? palette.secondaryBackground,
                    lineWidth: attributes.borderWidth
                )
            )
            .applyBackground(attributes.background)
            .font(attributes.font)
            .fontDesign(attributes.fontDesign)
            .fontWeight(attributes.fontWeight)
            .fontWidth(attributes.fontWidth)
            .lineLimit(config.minLines...)
    }

    @ViewBuilder
    private var inputMessage: some View {
        let (message, isError): (String?, Bool) = if let errorMessage = content.errorMessage {
            (errorMessage, true)
        } else if config.showStatusLabel {
            characterCountString(with: config.maxCharacters)
        } else {
            (nil, false)
        }

        if let message {
            Text(message)
                .foregroundColor(
                    isError && hasReceivedInput
                        ? themeObserver.theme.palette.error.toParraColor()
                        : themeObserver.theme.palette.secondaryText.toParraColor()
                )
                .padding(.trailing, 4)
        } else {
            EmptyView()
        }
    }

    var body: some View {
        VStack(spacing: 5) {
            applyStyle(
                to: TextEditor(text: $text)
            )
            .onChange(of: text) { _, newValue in
                hasReceivedInput = true

                content.textChanged?(newValue)
            }

            HStack {
                Spacer()

                inputMessage
            }
        }
    }

    private func characterCountString(with max: Int?) -> (String, Bool) {
        let characterCount = text.count

        guard let max else {
            return (String(characterCount), false)
        }

        return ("\(characterCount)/\(max)", characterCount > max)
    }
}
