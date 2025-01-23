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
        selectedOption: Binding<ParraReactionOption?>,
        optionGroups: [ParraReactionOptionGroup],
        reactor: ObservedObject<Reactor>,
        showLabels: Bool = true,
        searchEnabled: Bool = false
    ) {
        self.comment = comment
        self._selectedOption = selectedOption
        self.searchEnabled = searchEnabled
        self.showLabels = showLabels
        self.optionGroups = optionGroups
        self._reactor = reactor
    }

    // MARK: - Internal

    @Binding var selectedOption: ParraReactionOption?

    let optionGroups: [ParraReactionOptionGroup]
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
                    searchResults: searchResults,
                    selectedOption: _selectedOption,
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

    @ObservedObject private var reactor: Reactor

    @State private var search: String = ""
    @State private var showingReportAlert = false
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme

    private var searchEnabled: Bool

    private var searchResults: [ParraReactionOptionGroup] {
        if search.isEmpty {
            return optionGroups
        } else {
            return optionGroups.compactMap { group in
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
    NavigationView {
        FeedCommentReactionPickerView(
            comment: .validStates()[0],
            selectedOption: .constant(nil),
            optionGroups: ParraReactionOptionGroup.validStates(),
            reactor: .init(
                wrappedValue: .init(
                    feedItemId: .uuid,
                    reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                    reactions: ParraReactionSummary.validStates(),
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
