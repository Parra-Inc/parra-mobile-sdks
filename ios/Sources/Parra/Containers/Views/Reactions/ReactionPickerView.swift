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
        selectedOption: Binding<ParraReactionOption?>,
        optionGroups: [ParraReactionOptionGroup],
        showLabels: Bool = true,
        searchEnabled: Bool = false
    ) {
        self._selectedOption = selectedOption
        self.searchEnabled = searchEnabled
        self.showLabels = showLabels
        self.optionGroups = optionGroups
    }

    // MARK: - Internal

    @Binding var selectedOption: ParraReactionOption?

    let optionGroups: [ParraReactionOptionGroup]
    let showLabels: Bool

    var body: some View {
        ScrollView {
            ReactionPickerGridView(
                searchResults: searchResults,
                selectedOption: _selectedOption,
                showLabels: showLabels
            )
            .padding()
        }
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

    @State private var search: String = ""
    @Environment(\.parraComponentFactory) private var componentFactory

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
        ReactionPickerView(
            selectedOption: .constant(nil),
            optionGroups: [
                ParraReactionOptionGroup(
                    id: .uuid,
                    name: "Emojis",
                    description: "Standard system emojis",
                    options: [
                        ParraReactionOption(
                            id: .uuid,
                            name: "Thumbs Up",
                            type: .emoji,
                            value: "👍"
                        ),
                        ParraReactionOption(
                            id: .uuid,
                            name: "Thumbs Down",
                            type: .emoji,
                            value: "👎"
                        )
                    ]
                ),
                ParraReactionOptionGroup(
                    id: .uuid,
                    name: "Custom Emojis",
                    description: "Special emojis we made just for you",
                    options: [
                        ParraReactionOption(
                            id: .uuid,
                            name: "Take My Money",
                            type: .custom,
                            value: "https://emojis.slackmojis.com/emojis/images/1643514048/65/take_my_money.png?1643514048"
                        ),
                        ParraReactionOption(
                            id: .uuid,
                            name: "Beachball",
                            type: .custom,
                            value: "https://emojis.slackmojis.com/emojis/images/1643514710/7127/beach-ball.gif?1643514710"
                        ),
                        ParraReactionOption(
                            id: .uuid,
                            name: "Cool Doge",
                            type: .custom,
                            value: "https://emojis.slackmojis.com/emojis/images/1643514389/3643/cool-doge.gif?1643514389"
                        )
                    ]
                )
            ],
            searchEnabled: true
        )
    }
}
