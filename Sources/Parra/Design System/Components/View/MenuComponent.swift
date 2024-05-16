//
//  MenuComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

struct MenuComponent: View {
    // MARK: - Internal

    let config: MenuConfig
    let content: MenuContent
    let attributes: ParraAttributes.Menu

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
            .menuOrder(config.sortOrder)
            .applyMenuAttributes(
                attributes,
                using: themeObserver.theme
            )

            helperLabel
        }
        .applyPadding(
            size: attributes.padding,
            from: themeObserver.theme
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
    @EnvironmentObject private var componentFactory: ComponentFactory

    @State private var selectedOption: MenuContent.Option?

    private var elementOpacity: Double {
        return selectedOption != nil ? 1.0 : 0.6
    }

    @ViewBuilder private var titleLabel: some View {
        withContent(
            content: content.title
        ) { content in
            componentFactory.buildLabel(
                content: content,
                localAttributes: attributes.titleLabel
            )
        }
    }

    @ViewBuilder private var menuLabelText: some View {
        if let selectedOption {
            let content = LabelContent(text: selectedOption.title)

            componentFactory.buildLabel(
                content: content,
                localAttributes: attributes.selectedMenuItemLabels
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
                componentFactory.buildLabel(
                    content: normalContent,
                    localAttributes: attributes.unselectedMenuItemLabels
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

            let padding = themeObserver.theme.padding.value(
                for: attributes.padding
            )

            Image(systemName: "chevron.up.chevron.down")
                .padding(.vertical, 16)
                .foregroundStyle(.primary.opacity(elementOpacity))
                .frame(width: 24, height: 24)
                .padding(
                    .trailing,
                    padding.trailing
                )
        }
    }

    @ViewBuilder private var helperLabel: some View {
        withContent(
            content: content.helper
        ) { content in
            componentFactory.buildLabel(
                content: content,
                localAttributes: attributes.helperLabel
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

#Preview {
    ParraViewPreview { factory in
        factory.buildMenu(
            config: MenuConfig(),
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
