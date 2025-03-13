//
//  ReactionIconView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/23/25.
//

import SwiftUI

struct ReactionIconView: View {
    // MARK: - Lifecycle

    init(
        reaction: Binding<ParraReactionSummary>,
        size: CGFloat = 18
    ) {
        _reaction = reaction
        self.size = size
    }

    // MARK: - Internal

    var body: some View {
        switch reaction.type {
        case .emoji:
            Text(reaction.value)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .frame(
                    width: size,
                    height: size
                )
        case .custom:
            if let url = URL(string: reaction.value) {
                componentFactory.buildAsyncImage(
                    config: ParraAsyncImageConfig(
                        aspectRatio: 1.0,
                        contentMode: .fit
                    ),
                    content: ParraAsyncImageContent(
                        url: url,
                        originalSize: CGSize(width: size, height: size)
                    ),
                    localAttributes: ParraAttributes.AsyncImage(
                        size: CGSize(width: size, height: size)
                    )
                )
            }
        }
    }

    // MARK: - Private

    @Binding private var reaction: ParraReactionSummary
    private var size: CGFloat

    @Environment(\.parraComponentFactory) private var componentFactory
}
