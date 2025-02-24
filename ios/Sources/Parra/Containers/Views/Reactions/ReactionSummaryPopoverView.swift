//
//  ReactionSummaryPopoverView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/25.
//

import SwiftUI

struct ReactionSummaryPopoverView: View {
    // MARK: - Lifecycle

    init(
        reaction: Binding<ParraReactionSummary>
    ) {
        _reaction = reaction
    }

    // MARK: - Internal

    var body: some View {
        VStack(spacing: 16) {
            ReactionIconView(reaction: _reaction, size: 44.0)
                .padding()
                .background(
                    theme.palette.secondaryBackground.toParraColor()
                )
                .applyCornerRadii(size: .xl, from: theme)

            if let names = namesList(from: reaction.users?.elements) {
                (
                    Text(names)
                        + Text(" reacted with \(reaction.name)").foregroundStyle(
                            .secondary
                        )
                )
                .applyTextAttributes(
                    .default(
                        with: .callout,
                        color: theme.palette.primaryText.toParraColor(),
                        alignment: .center
                    ),
                    using: theme
                )
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 30)
        .frame(maxWidth: 340, maxHeight: 500)
        .presentationCompactAdaptation(.popover)
        .background(
            theme.palette.primaryBackground.toParraColor()
        )
    }

    // MARK: - Private

    @Binding private var reaction: ParraReactionSummary

    @Environment(\.parraTheme) private var theme

    private func namesList(
        from stubs: [ParraUserNameStub]?
    ) -> String? {
        guard let stubs, !stubs.isEmpty else {
            return nil
        }

        var names = stubs.map { stub in
            return stub.name
        }

        let remaining = reaction.count - names.count
        if remaining == 0 {
            // noop
        } else if remaining == 1 {
            names.append("1 other")
        } else {
            names.append("\(remaining) others")
        }

        return names.toCommaList()
    }
}
