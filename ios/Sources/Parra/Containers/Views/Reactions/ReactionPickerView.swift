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

    @Environment(\.dismiss) var dismiss

    @Binding var selectedOption: ParraReactionOption?

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    let optionGroups: [ParraReactionOptionGroup]
    let showLabels: Bool

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(searchResults, id: \.self) { group in
                    Section {
                        ForEach(group.options, id: \.self) { reactionOption in
                            Button {
                                selectedOption = reactionOption
                                dismiss()
                            } label: {
                                VStack {
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill((
                                            selectedOption == reactionOption ? .blue :
                                                Color
                                                .gray
                                        ).opacity(0.4))
                                        .frame(width: 64, height: 64)
                                        .overlay {
                                            reactionContent(for: reactionOption)
                                        }

                                    if showLabels {
                                        Text(reactionOption.name)
                                            .font(.caption2)
                                            .multilineTextAlignment(.center)
                                            .lineLimit(2, reservesSpace: true)
                                            .backgroundStyle(.red)
                                    }
                                }
                            }
                            // Required to prevent highlighting the button then dragging the scroll
                            // view from causing the button to be pressed.
                            .simultaneousGesture(TapGesture())
                            .buttonStyle(.plain)
                        }
                    } header: {
                        VStack {
                            Text(group.name)
                                .font(.headline)

                            if let description = group.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(
                            maxWidth: .infinity,
                            alignment: .center
                        )
                    }
                }
            }
            .safeAreaPadding(.top)
            .padding(.horizontal)
        }
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

    @ViewBuilder
    private func reactionContent(
        for reactionOption: ParraReactionOption
    ) -> some View {
        switch reactionOption.type {
        case .custom:
            if let url = URL(string: reactionOption.value) {
                if url.lastPathComponent.hasSuffix(".gif") {
                    GifImageView(url: url)
                        .frame(
                            width: 40.0,
                            height: 40.0
                        )
                } else {
                    componentFactory.buildAsyncImage(
                        config: ParraImageConfig(
                            aspectRatio: 1.0,
                            contentMode: .fit
                        ),
                        content: ParraAsyncImageContent(
                            url: url
                        ),
                        localAttributes: ParraAttributes.AsyncImage(
                            size: CGSize(
                                width: 40.0,
                                height: 40.0
                            )
                        )
                    )
                }
            }
        case .emoji:
            Text(reactionOption.value)
                .font(.system(size: 500))
                .minimumScaleFactor(0.01)
                .frame(
                    width: 40.0,
                    height: 40.0
                )
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
