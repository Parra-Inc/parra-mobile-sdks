//
//  ReactionPickerGridView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct ReactionPickerGridView: View {
    // MARK: - Internal

    var searchResults: [ParraReactionOptionGroup]
    @Binding var selectedOption: ParraReactionOption?
    var showLabels: Bool

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    var body: some View {
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
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.dismiss) private var dismiss

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
