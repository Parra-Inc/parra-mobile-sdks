//
//  CreatorUpdateTagBadge.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import SwiftUI

struct CreatorUpdateTagBadge: View {
    // MARK: - Lifecycle

    init(title: String, icon: String? = nil, style: Style = .primary) {
        self.title = title
        self.icon = icon
        self.style = style
    }

    // MARK: - Internal

    enum Style {
        case primary
        case secondary
    }

    var title: String
    var icon: String?
    var style: Style

    var body: some View {
        let background = switch style {
        case .primary:
            theme.palette.primaryChipBackground
        case .secondary:
            theme.palette.secondaryChipBackground
        }

        let textColor = switch style {
        case .primary:
            theme.palette.primaryChipText.toParraColor()
        case .secondary:
            theme.palette.secondaryChipText.toParraColor()
        }

        HStack(alignment: .center) {
            Label {
                componentFactory.buildLabel(
                    text: title,
                    localAttributes: .default(
                        with: .caption,
                        color: textColor
                    )
                )
            } icon: {
                if let icon {
                    Image(systemName: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            maxHeight: 10
                        )
                        .foregroundStyle(theme.palette.primary)
                }
            }
            .labelStyle(CustomLabel(spacing: 4))
        }
        .padding(.horizontal, 10)
        .frame(
            height: 26
        )
        .background(background)
        .applyCornerRadii(size: .md, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
}
