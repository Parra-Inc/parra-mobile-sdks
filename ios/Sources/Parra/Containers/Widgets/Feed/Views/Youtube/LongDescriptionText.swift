//
//  LongDescriptionText.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/25.
//

import SwiftUI

struct LongDescriptionText<Content>: View where Content: View {
    // MARK: - Lifecycle

    init(
        text: AttributedString,
        style: Style = .moreLess,
        lineLimit: Int = 4,
        contentModifier: @escaping (_ text: Text) -> Content
    ) {
        self.text = text
        self.style = style
        self.lineLimit = lineLimit
        self.contentModifier = contentModifier
    }

    // MARK: - Internal

    enum Style {
        case moreLess
        case chevron
    }

    var body: some View {
        VStack {
            contentModifier(Text(text))
                .frame(
                    maxWidth: .infinity,
                    alignment: .leading
                )
                .lineLimit(expanded ? nil : lineLimit)
                .background(GeometryReader { geometry in
                    Color.clear.onAppear {
                        determineTruncation(geometry)
                    }
                })

            if truncated {
                toggleButton
            }
        }
    }

    var toggleButton: some View {
        Button {
            withAnimation {
                expanded.toggle()
            }
        } label: {
            HStack {
                Spacer()

                switch style {
                case .moreLess:
                    Text(expanded ? "show less" : "... more")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                case .chevron:
                    Image(
                        systemName: expanded ? "chevron.up" : "chevron.down"
                    )
                    .fontWeight(.semibold)
                    .foregroundColor(
                        theme.palette.secondaryChipBackground.toParraColor()
                    )
                    .padding(.top, 8)

                    Spacer()
                }
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Private

    @State private var expanded = false
    @State private var truncated = false

    private var text: AttributedString
    private var style: Style
    private var lineLimit: Int
    private var contentModifier: (_ text: Text) -> Content

    @Environment(\.parraTheme) private var theme

    private func determineTruncation(_ geometry: GeometryProxy) {
        let total = NSAttributedString(text)
            .boundingRect(
                with: CGSize(
                    width: geometry.size.width,
                    height: .greatestFiniteMagnitude
                ),
                options: [.usesLineFragmentOrigin],
                context: nil
            )

        if total.size.height > geometry.size.height {
            truncated = true
        }
    }
}
