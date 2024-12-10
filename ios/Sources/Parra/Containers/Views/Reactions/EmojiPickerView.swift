//
//  EmojiPickerView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import SwiftUI

struct EmojiPickerView: View {
    // MARK: - Lifecycle

    init(
        selectedEmoji: Binding<EmojiUtils.Emoji?>,
        searchEnabled: Bool = false,
        selectedColor: Color = .blue
    ) {
        self._selectedEmoji = selectedEmoji
        self.selectedColor = selectedColor
        self.searchEnabled = searchEnabled
        self.emojis = EmojiUtils.allEmojis
    }

    // MARK: - Internal

    @Environment(\.dismiss) var dismiss

    @Binding var selectedEmoji: EmojiUtils.Emoji?

    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]

    let emojis: [EmojiUtils.Emoji]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(searchResults, id: \.self) { emoji in
                    Button {
                        selectedEmoji = emoji
                        dismiss()
                    } label: {
                        VStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill((
                                    selectedEmoji == emoji ? selectedColor : Color
                                        .gray
                                ).opacity(0.4))
                                .frame(width: 64, height: 64)
                                .overlay {
                                    Text(emoji.value)
                                        .font(.largeTitle)
                                }

                            Text(emoji.name)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .lineLimit(2, reservesSpace: true)
                                .backgroundStyle(.red)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal)
        }
        .frame(maxHeight: .infinity)
        .searchable(text: $search)
    }

    // MARK: - Private

    @State private var search: String = ""

    private var selectedColor: Color
    private var searchEnabled: Bool

    private var searchResults: [EmojiUtils.Emoji] {
        if search.isEmpty {
            return emojis
        } else {
            return emojis
                .filter { $0.name.lowercased().contains(search.lowercased()) }
        }
    }
}

#Preview {
    EmojiPickerView(
        selectedEmoji: .constant(nil)
    )
}
