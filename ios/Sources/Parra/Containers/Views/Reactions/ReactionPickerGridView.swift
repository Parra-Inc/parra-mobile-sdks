//
//  ReactionPickerGridView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct ReactionPickerGridView: View {
    // MARK: - Lifecycle

    init(
        reactor: StateObject<Reactor>,
        searchResults: [ParraReactionOptionGroup],
        showLabels: Bool
    ) {
        self._reactor = reactor
        self.searchResults = searchResults
        self.showLabels = showLabels
    }

    // MARK: - Internal

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 20) {
            ForEach(searchResults, id: \.self) { group in
                Section {
                    ForEach(group.options, id: \.self) { reactionOption in
                        ReactionPickerButton(
                            reactor: _reactor,
                            reactionOption: reactionOption,
                            showLabels: showLabels
                        )
                    }
                } header: {
                    VStack {
                        componentFactory.buildLabel(
                            text: group.name,
                            localAttributes: .default(with: .headline)
                        )

                        if let description = group.description {
                            componentFactory.buildLabel(
                                text: description,
                                localAttributes: .default(with: .caption)
                            )
                        }
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .center
                    )
                }
            }
        }
    }

    // MARK: - Private

    @StateObject private var reactor: Reactor
    private var searchResults: [ParraReactionOptionGroup]
    private var showLabels: Bool

    @Environment(\.parraComponentFactory) private var componentFactory
}
