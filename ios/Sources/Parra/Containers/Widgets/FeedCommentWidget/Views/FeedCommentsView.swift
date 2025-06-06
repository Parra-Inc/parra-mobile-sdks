//
//  FeedCommentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct FeedCommentsView: View {
    // MARK: - Lifecycle

    init(
        feedItem: ParraFeedItem,
        comments: Binding<[ParraComment]>,
        requiredEntitlement: ParraEntitlement?,
        context: String?,
        contentObserver: StateObject<FeedCommentWidget.ContentObserver>,
        itemAtIndexDidAppear: @escaping (_: Int) -> Void
    ) {
        self.feedItem = feedItem
        self._comments = comments
        self.requiredEntitlement = requiredEntitlement
        self.context = context
        self._contentObserver = contentObserver
        self.itemAtIndexDidAppear = itemAtIndexDidAppear
    }

    // MARK: - Internal

    let feedItem: ParraFeedItem
    @Binding var comments: [ParraComment]
    let requiredEntitlement: ParraEntitlement?
    let context: String?
    @StateObject var contentObserver: FeedCommentWidget.ContentObserver
    var itemAtIndexDidAppear: (_: Int) -> Void

    var body: some View {
        if let requiredEntitlement {
            VStack(alignment: .center, spacing: 8) {
                componentFactory.buildLabel(
                    text: "\(requiredEntitlement.title) required",
                    localAttributes: .default(with: .title3)
                )

                componentFactory.buildLabel(
                    text: "Comments are available with the \(requiredEntitlement.title) membership. Upgrade to join the conversation.",
                    localAttributes: .default(with: .subheadline)
                )

                componentFactory.buildPlainButton(
                    config: ParraTextButtonConfig(
                        type: .primary,
                        size: .medium,
                        isMaxWidth: false
                    ),
                    text: "Get \(requiredEntitlement.title)"
                ) {
                    paywallPresentationState = .loading
                }
            }
            .padding(.top, 40)
            .padding(.bottom, 80)
            .presentParraPaywall(
                entitlement: requiredEntitlement.key,
                context: context,
                presentationState: $paywallPresentationState
            )
        } else {
            ForEach(
                Array(comments.enumerated()),
                id: \.element
            ) { index, comment in
                FeedCommentView(
                    feedItem: feedItem,
                    comment: comment,
                    api: parra.parraInternal.api,
                    contentObserver: _contentObserver
                )
                .id(comment)
                .onAppear {
                    itemAtIndexDidAppear(index)
                }
            }
        }
    }

    // MARK: - Private

    @State private var paywallPresentationState = ParraSheetPresentationState.ready

    @Environment(\.parra) private var parra
    @Environment(\.parraComponentFactory) private var componentFactory
}
