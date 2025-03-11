//
//  CreatorUpdateTagBadge.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import SwiftUI

struct CreatorUpdateTagBadge: View {
    // MARK: - Lifecycle

    init(title: String, icon: String, style: Style = .primary) {
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
    var icon: String
    var style: Style

    var body: some View {
        let background = switch style {
        case .primary:
            theme.palette.primaryBackground
        case .secondary:
            theme.palette.secondaryBackground
        }

        HStack(alignment: .center) {
            Label {
                componentFactory.buildLabel(
                    text: title,
                    localAttributes: .default(with: .callout)
                )
            } icon: {
                Image(systemName: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        maxHeight: 14
                    )
            }
            .labelStyle(CustomLabel(spacing: 6))
        }
        .padding(.horizontal, 10)
        .frame(
            height: 32
        )
        .background(background)
        .applyCornerRadii(size: .md, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
}
