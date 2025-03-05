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
        searchEnabled: Bool = false,
        onDeleteComment: @escaping (_ commentId: String) -> Void
    ) {
        self.comment = comment
        self.searchEnabled = searchEnabled
        self.showLabels = showLabels
        self._reactor = reactor
        self.onDeleteComment = onDeleteComment
    }

    // MARK: - Internal

    var showLabels: Bool
    var comment: ParraComment
    var onDeleteComment: (_ commentId: String) -> Void

    var isCurrentUser: Bool {
        return comment.user.id == authState.user?.info.id
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Spacer()

                    Menu {
                        if isCurrentUser {
                            // Users can only delete their own comments.
                            Button("Delete Commment", systemImage: "trash") {
                                showingDeleteAlert = true
                            }
                        } else {
                            // Users don't need to report their own comments.
                            Button("Report Comment", systemImage: "flag") {
                                showingReportAlert = true
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                PickerInlineCommentView(
                    comment: comment,
                    reactor: _reactor
                )

                ReactionPickerGridView(
                    reactor: _reactor,
                    searchResults: searchResults,
                    showLabels: showLabels
                )
                .disabled(isCurrentUser)
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
            "Report Comment",
            isPresented: $showingReportAlert
        ) {
            ReportAlertContentView(
                commentId: comment.id
            )
        } message: {
            Text(
                "Are you sure you want to report this comment as inappropriate? This cannot be undone."
            )
        }
        .alert(
            "Delete Comment",
            isPresented: $showingDeleteAlert
        ) {
            DeleteCommentAlertContentView(
                commentId: comment.id
            ) {
                onDeleteComment(comment.id)
            }
        } message: {
            Text(
                "Are you sure you want to delete this comment? This cannot be undone."
            )
        }
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor

    @State private var search: String = ""
    @State private var showingReportAlert = false
    @State private var showingDeleteAlert = false
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAuthState) private var authState

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
                            return .validStates()[0]
                        },
                        removeReaction: { _, _, _ in
                        }
                    )
                ),
                showLabels: false,
                searchEnabled: false
            ) { _ in }
        }
    }
}
