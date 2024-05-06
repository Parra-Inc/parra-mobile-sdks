//
//  ParraAttributedTextButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 1/31/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PlainButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.PlainButton
    let pressedAttributes: ParraAttributes.PlainButton
    let disabledAttributes: ParraAttributes.PlainButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            disabledAttributes
        } else if configuration.isPressed {
            pressedAttributes
        } else {
            attributes
        }

        LabelComponent(
            content: content.text,
            attributes: currentAttributes.label
        )
        .applyPlainButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

struct OutlinedButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.OutlinedButton
    let pressedAttributes: ParraAttributes.OutlinedButton
    let disabledAttributes: ParraAttributes.OutlinedButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            disabledAttributes
        } else if configuration.isPressed {
            pressedAttributes
        } else {
            attributes
        }

        LabelComponent(
            content: content.text,
            attributes: currentAttributes.label
        )
        .applyOutlinedButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

struct ContainedButtonStyle: ButtonStyle, ParraAttributedStyle {
    // MARK: - Internal

    let config: TextButtonConfig
    let content: TextButtonContent

    let attributes: ParraAttributes.ContainedButton
    let pressedAttributes: ParraAttributes.ContainedButton
    let disabledAttributes: ParraAttributes.ContainedButton

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        let currentAttributes = if content.isDisabled {
            disabledAttributes
        } else if configuration.isPressed {
            pressedAttributes
        } else {
            attributes
        }

        LabelComponent(
            content: content.text,
            attributes: currentAttributes.label
        )
        .applyContainedButtonAttributes(
            currentAttributes,
            using: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

struct ParraAttributedTextButtonStyle: ButtonStyle, ParraAttributedStyle {
    let config: TextButtonConfig
    let content: TextButtonContent
    let attributes: TextButtonAttributes
    let theme: ParraTheme

    @ViewBuilder
    func makeBody(configuration: Configuration) -> some View {
        EmptyView()
    }
}
