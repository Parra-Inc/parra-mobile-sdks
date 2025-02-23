//
//  ReactionCountView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/25.
//

import SwiftUI

struct ReactionCountView: View {
    // MARK: - Lifecycle

    init(
        reactor: StateObject<Reactor>
    ) {
        self._reactor = reactor
    }

    // MARK: - Internal

    var body: some View {
        let accentColor = theme.palette.primaryText
            .toParraColor()
            .opacity(0.7)

        componentFactory.buildLabel(
            text: "\(reactor.totalReactions)",
            localAttributes: .init(
                text: ParraAttributes.Text(
                    style: .caption,
                    color: accentColor
                )
            )
        )
        .onLongPressGesture {
            isReactionPopoverPresented = true
        }
        .popover(
            isPresented: $isReactionPopoverPresented
        ) {
            ReactionMultipleSummaryPopoverView(
                reactions: $reactor.currentReactions
            )
        }
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor

    @State private var isReactionPopoverPresented = false

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
