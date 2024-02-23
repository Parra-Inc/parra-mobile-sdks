//
//  MenuComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct MenuComponent: MenuComponentType {
    // MARK: - Internal

    var config: MenuConfig
    var content: MenuContent
    var style: ParraAttributedMenuStyle

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // spacing controlled by individual component padding.
            titleLabel

            Menu {
                ForEach(content.options.indices, id: \.self) { index in
                    menuItem(for: index)
                }
            } label: {
                menuLabel
            }
            .menuStyle(style)

            helperLabel
        }
        .padding(style.attributes.padding ?? .zero)
        .applyBackground(style.attributes.background)
    }

    static func applyStandardCustomizations(
        onto inputAttributes: MenuAttributes?,
        theme: ParraTheme,
        config: MenuConfig
    ) -> MenuAttributes {
        let title = LabelAttributes.defaultFormTitle(
            in: theme,
            with: config.title
        )
        let helper = LabelAttributes.defaultFormHelper(
            in: theme,
            with: config.helper
        )

        let menuItem = LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: theme.palette.primaryText.toParraColor()
                    .opacity(0.75),
                fontWeight: .regular,
                padding: EdgeInsets(vertical: 18.5, horizontal: 14)
            ),
            theme: theme,
            config: config.menuOption
        )

        let menuItemSelected = LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: theme.palette.primaryText.toParraColor(),
                fontWeight: .medium,
                padding: EdgeInsets(vertical: 18.5, horizontal: 14)
            ),
            theme: theme,
            config: config.menuOptionSelected
        )

        return inputAttributes ?? MenuAttributes(
            title: title,
            helper: helper,
            menuItem: menuItem,
            menuItemSelected: menuItemSelected,
            sortOrder: .fixed,
            tint: theme.palette.secondaryText.toParraColor(),
            cornerRadius: .medium,
            padding: EdgeInsets(vertical: 0, horizontal: 0),
            borderWidth: 1
        )
    }

    // MARK: - Private

    @State private var selectedOption: MenuContent.Option?

    private var elementOpacity: Double {
        return selectedOption != nil ? 1.0 : 0.6
    }

    @ViewBuilder private var titleLabel: some View {
        if let title = content.title, let titleStyle = style.titleStyle {
            LabelComponent(
                content: title,
                style: titleStyle
            )
        }
    }

    @ViewBuilder private var menuLabelText: some View {
        if let selectedOption {
            let content = LabelContent(text: selectedOption.title)

            LabelComponent(
                content: content,
                style: style.menuOptionSelectedStyle.withContent(
                    content: content
                )
            )
        } else {
            let normalContent: LabelContent? = if let placeholder = content
                .placeholder
            {
                placeholder
            } else if let firstOption = content.options.first {
                LabelContent(text: firstOption.title)
            } else {
                nil
            }

            if let normalContent {
                LabelComponent(
                    content: normalContent,
                    style: style.menuOptionStyle.withContent(
                        content: normalContent
                    )
                )
            } else {
                EmptyView()
            }
        }
    }

    @ViewBuilder private var menuLabel: some View {
        HStack {
            menuLabelText

            Spacer()

            Image(systemName: "chevron.up.chevron.down")
                .padding(.vertical, 16)
                .foregroundStyle(.primary.opacity(elementOpacity))
                .frame(width: 24, height: 24)
                .padding(
                    .trailing,
                    style.menuOptionStyle.attributes.padding?
                        .trailing ?? 0
                )
        }
    }

    @ViewBuilder private var helperLabel: some View {
        if let helper = content.helper,
           let helperStyle = style.helperStyle
        {
            LabelComponent(
                content: helper,
                style: helperStyle
            )
        }
    }

    @ViewBuilder
    private func menuItem(for index: Int) -> some View {
        let option = content.options[index]

        if option == selectedOption {
            Button(option.title, systemImage: "checkmark") {
                didSelect(option: option)
            }
        } else {
            Button(option.title) {
                didSelect(option: option)
            }
        }
    }

    private func didSelect(option: MenuContent.Option?) {
        selectedOption = option

        content.optionSelectionChanged?(option)
    }
}

private func renderMenu(
    config: MenuConfig,
    content: MenuContent,
    attributes: MenuAttributes? = nil,
    theme: ParraTheme = .default
) -> some View {
    let mergedAttributes = MenuComponent.applyStandardCustomizations(
        onto: attributes,
        theme: theme,
        config: config
    )

    return MenuComponent(
        config: config,
        content: content,
        style: ParraAttributedMenuStyle(
            config: config,
            content: content,
            attributes: mergedAttributes,
            theme: theme
        )
    )
}

#Preview {
    return VStack {
        renderMenu(
            config: FeedbackFormConfig.default.selectFields,
            content: MenuContent(
                title: "We want to hear from you",
                placeholder: "Please select an option",
                helper: "You know, so we know which one you want!",
                options: [
                    MenuContent.Option(
                        id: "first",
                        title: "First option",
                        value: "first"
                    ),
                    MenuContent.Option(
                        id: "second",
                        title: "Second option",
                        value: "second"
                    ),
                    MenuContent.Option(
                        id: "third",
                        title: "Third option",
                        value: "third"
                    ),
                    MenuContent.Option(
                        id: "fourth",
                        title: "Fourth option",
                        value: "fourth"
                    )
                ],
                optionSelectionChanged: nil
            )
        )
    }
    .padding()
}
