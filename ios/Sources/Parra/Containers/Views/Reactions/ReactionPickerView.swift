//
//  ReactionPickerView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import SwiftUI

struct ReactionPickerView: View {
    // MARK: - Lifecycle

    init(
        reactor: StateObject<Reactor>,
        showLabels: Bool = true,
        searchEnabled: Bool = false
    ) {
        _reactor = reactor
        self.searchEnabled = searchEnabled
        self.showLabels = showLabels
    }

    // MARK: - Internal

    var body: some View {
        ScrollView {
            ReactionPickerGridView(
                reactor: _reactor,
                searchResults: searchResults,
                showLabels: showLabels
            )
            .padding()
        }
        .background(theme.palette.secondaryBackground)
        .contentMargins(
            .top,
            EdgeInsets(vertical: 16, horizontal: 0),
            for: .automatic
        )
        .frame(maxHeight: .infinity)
        .if(searchEnabled) { ctx in
            ctx.searchable(text: $search)
        }
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor

    @State private var search: String = ""
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var theme

    private let showLabels: Bool
    private let searchEnabled: Bool

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
            ReactionPickerView(
                reactor: StateObject(
                    wrappedValue: Reactor(
                        feedItemId: .uuid,
                        reactionOptionGroups: ParraReactionOptionGroup.validStates(),
                        reactions: ParraReactionSummary.validStates(),
                        api: parra.parraInternal.api
                    )
                ),
                searchEnabled: true
            )
        }
    }
}
