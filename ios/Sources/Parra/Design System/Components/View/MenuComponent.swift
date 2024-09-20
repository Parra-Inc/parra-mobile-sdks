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

    let config: ParraMenuConfig
    let content: ParraMenuContent
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
                using: parraTheme
            )

            helperLabel
        }
        .applyPadding(
            size: attributes.padding,
            from: parraTheme
        )
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme
    @Environment(ParraComponentFactory.self) private var componentFactory

    @State private var selectedOption: ParraMenuContent.Option?

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
            let content = ParraLabelContent(text: selectedOption.title)

            componentFactory.buildLabel(
                content: content,
                localAttributes: attributes.selectedMenuItemLabels
            )
        } else {
            let normalContent: ParraLabelContent? = if let placeholder = content
                .placeholder
            {
                placeholder
            } else if let firstOption = content.options.first {
                ParraLabelContent(text: firstOption.title)
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

            let padding = parraTheme.padding.value(
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

    private func didSelect(option: ParraMenuContent.Option?) {
        selectedOption = option

        content.optionSelectionChanged?(option)
    }
}

#Preview {
    ParraViewPreview { factory in
        factory.buildMenu(
            config: ParraMenuConfig(),
            content: ParraMenuContent(
                title: "We want to hear from you",
                placeholder: "Please select an option",
                helper: "You know, so we know which one you want!",
                options: [
                    ParraMenuContent.Option(
                        id: "first",
                        title: "First option",
                        value: "first"
                    ),
                    ParraMenuContent.Option(
                        id: "second",
                        title: "Second option",
                        value: "second"
                    ),
                    ParraMenuContent.Option(
                        id: "third",
                        title: "Third option",
                        value: "third"
                    ),
                    ParraMenuContent.Option(
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
