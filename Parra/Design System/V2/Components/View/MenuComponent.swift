//
//  MenuComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

//struct LabelComponent: LabelComponentType {

struct MenuComponent: MenuComponentType {
    struct Option: Identifiable, Hashable {
        let id: String
        let title: String
        let value: String?
    }

    var config: MenuConfig
    var content: MenuContent
    var style: ParraAttributedMenuStyle

    @State private var selectedOption: Option?

    private var elementOpacity: Double {
        return selectedOption != nil ? 1.0 : 0.6
    }

    private var currentStyle: ParraAttributedMenuStyle {
        if selectedOption == nil {
            style
        } else {
            style
        }
    }

    static func applyStandardCustomizations(
        onto inputAttributes: MenuAttributes?,
        theme: ParraTheme,
        config: MenuConfig
    ) -> MenuAttributes {
        let label = LabelComponent.applyStandardCustomizations(
            onto: LabelAttributes(
                fontColor: theme.palette.primaryText.toParraColor(),
                fontWeight: .regular,
                padding: EdgeInsets(vertical: 18.5, horizontal: 0)
            ),
            theme: theme,
            config: config.label
        )

        return inputAttributes ?? MenuAttributes(
            label: label,
            labelWithSelection: label.withUpdates(
                updates: LabelAttributes(
                    fontWeight: .medium
                )
            ),
            sortOrder: .fixed,
            tint: theme.palette.secondaryText.toParraColor(),
            cornerRadius: RectangleCornerRadii(allCorners: 8),
            padding: EdgeInsets(vertical: 0, horizontal: 14),
            borderWidth: 1
        )
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

    @ViewBuilder
    private var menuLabel: some View {

        if let selectedOption {
            let labelContent = content.withSelection(of: selectedOption).label

            LabelComponent(
                config: config.label,
                content: labelContent,
                style: style.labelWithSelectionStyle.withContent(content: labelContent)
            )
        } else {
            LabelComponent(
                config: config.label,
                content: content.label,
                style: style.labelStyle
            )
        }
    }

    var body: some View {
        Menu {
            ForEach(content.options.indices, id: \.self) { index in
                menuItem(for: index)
            }
        } label: {
            HStack {
                // TODO: Use LabelComponent for this whole thing and support passing spacing/icon config to it
                menuLabel

                Spacer()

                Image(systemName: "chevron.up.chevron.down")
                    .padding(.vertical, 16)
                    .foregroundStyle(.primary.opacity(elementOpacity))
                    .frame(width: 24, height: 24)
            }
        }
        .menuStyle(style)
    }

    private func didSelect(option: Option) {
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
            config: MenuConfig(
                label: LabelConfig(
                    type: .body
                )
            ),
            content: MenuContent(
                label: LabelContent(
                    text: "Select an option"
                ),
                options: [
                    MenuComponent.Option(
                        id: "first",
                        title: "First option",
                        value: "first"
                    ),
                    MenuComponent.Option(
                        id: "second",
                        title: "Second option",
                        value: "second"
                    ),
                    MenuComponent.Option(
                        id: "third",
                        title: "Third option",
                        value: "third"
                    ),
                    MenuComponent.Option(
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

