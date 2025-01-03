//
//  ParraMenuComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

public struct ParraMenuComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraMenuConfig,
        content: ParraMenuContent,
        attributes: ParraAttributes.Menu,
        selectedOption: ParraMenuContent.Option? = nil
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
        self.selectedOption = selectedOption
    }

    // MARK: - Public

    public let config: ParraMenuConfig
    public let content: ParraMenuContent
    public let attributes: ParraAttributes.Menu

    public var body: some View {
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
    @Environment(\.parraComponentFactory) private var componentFactory

    @State private var selectedOption: ParraMenuContent.Option?
    @State private var hasReceivedInput = false

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

            Image(systemName: "chevron.up.chevron.down")
                .padding(.vertical, 16)
                .foregroundStyle(.primary.opacity(elementOpacity))
                .frame(width: 24, height: 24)
                .padding(
                    .trailing,
                    8
                )
        }
    }

    @ViewBuilder private var helperLabel: some View {
        let (message, isError): (
            String?,
            Bool
        ) = if let errorMessage = content.errorMessage {
            // Even though we're displaying the error message, we only want to
            // render it as an error if input has already been received. This
            // prevents errors from being as apparent before the user has had
            // the chance to try to enter anything.
            (errorMessage, hasReceivedInput)
        } else if let helperContent = content.helper {
            (helperContent.text, false)
        } else {
            (nil, false)
        }

        let content = if let message {
            ParraLabelContent(text: message)
        } else {
            ParraLabelContent(text: "")
        }

        if content.text.isEmpty {
            EmptyView()
        } else {
            let helperAttributes = isError
                ? attributes.errorLabel : attributes.helperLabel

            componentFactory.buildLabel(
                content: content,
                localAttributes: helperAttributes
            )
            .lineLimit(1)
            .padding(.top, 2)
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
        hasReceivedInput = true

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
