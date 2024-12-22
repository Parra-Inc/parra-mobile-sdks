//
//  PickerInlineCommentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/19/24.
//

import SwiftUI

struct PickerInlineCommentView: View {
    // MARK: - Lifecycle

    init(
        comment: ParraComment,
        reactor: ObservedObject<Reactor>
    ) {
        self._reactor = reactor
        self.comment = comment
    }

    // MARK: - Internal

    var body: some View {
        VStack {
            FeedCommentContentView(comment: comment) {
                PickerInlineReactionView(reactor: _reactor)
            }
            .frame(
                maxWidth: .infinity
            )
        }
        .padding()
        .background(
            theme.palette.secondaryBackground
        )
        .applyCornerRadii(size: .md, from: theme)
    }

    // MARK: - Private

    private let comment: ParraComment
    @ObservedObject private var reactor: Reactor

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
