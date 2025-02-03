//
//  FeedCommentReactionPickerView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct FeedCommentReactionPickerView: View {
    // MARK: - Lifecycle

    init(
        comment: ParraComment,
        reactor: StateObject<Reactor>,
        showLabels: Bool = true,
        searchEnabled: Bool = false
    ) {
        self.comment = comment
        self.searchEnabled = searchEnabled
        self.showLabels = showLabels
        self._reactor = reactor
    }

    // MARK: - Internal

    let showLabels: Bool
    let comment: ParraComment

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    PickerInlineCommentView(
                        comment: comment,
                        reactor: _reactor
                    )

                    Spacer()

                    componentFactory.buildImageButton(
                        config: ParraImageButtonConfig(
                            type: .primary,
                            size: .custom(
                                CGSize(width: 16, height: 16)
                            ),
                            variant: .plain
                        ),
                        content: ParraImageButtonContent(
                            image: .symbol("flag", .monochrome)
                        ),
                        localAttributes: ParraAttributes.ImageButton(
                            normal: ParraAttributes.ImageButton.StatefulAttributes(
                                padding: .zero
                            )
                        )
                    ) {
                        showingReportAlert = true
                    }
                }

                ReactionPickerGridView(
                    reactor: _reactor,
                    searchResults: searchResults,
                    showLabels: showLabels
                )
            }
            .padding(.top, 30)
            .padding(.horizontal)
        }
        .background(theme.palette.primaryBackground)
        .frame(maxHeight: .infinity)
        .if(searchEnabled) { ctx in
            ctx.searchable(text: $search)
        }
        .alert(
            "Report comment",
            isPresented: $showingReportAlert
        ) {
            ReportAlertContentView(
                commentId: comment.id
            )
        } message: {
            Text(
                "Are you sure you want to report this comment as inappropriate? This action cannot be undone."
            )
        }
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor

    @State private var search: String = ""
    @State private var showingReportAlert = false
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme

    private var searchEnabled: Bool

    private var searchResults: [ParraReactionOptionGroup] {
        if search.isEmpty {
            return reactor.reactionOptionGroups
        } else {
            return reactor.reactionOptionGroups.compactMap { group in
                let filtered = group.options.filter { option in
                    option.name.lowercased().contains(search.lowercased())
                }

                if filtered.isEmpty {
                    return nil
                }

                return ParraReactionOptionGroup(
                    id: group.id,
                    name: group.name,
                    description: group.description,
                    options: filtered
                )
            }
        }
    }
}

#Preview {
    ParraContainerPreview<FeedWidget>(config: .default) { parra, _, _ in
        NavigationView {
            FeedCommentReactionPickerView(
                comment: .validStates()[0],
                reactor: .init(
                    wrappedValue: Reactor(
                        feedItemId: .uuid,
                        reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                        reactions: ParraReactionSummary.validStates(),
                        api: parra.parraInternal.api,
                        submitReaction: { _, _, _ in
                            return .uuid
                        },
                        removeReaction: { _, _, _ in
                        }
                    )
                ),
                showLabels: false,
                searchEnabled: false
            )
        }
    }
}
