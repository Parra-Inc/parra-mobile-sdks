//
//  AddCommentBarView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

struct AddCommentBarView: View {
    // MARK: - Lifecycle

    init(
        allowSubmission: Binding<Bool>,
        characterLimit: Int = 250,
        submitComment: @escaping (String) -> Bool
    ) {
        self._allowSubmission = allowSubmission
        self.characterLimit = characterLimit
        self.submitComment = submitComment
        self._submitButtonContent = State(
            initialValue: ParraImageButtonContent(
                image: .symbol("arrow.up.circle.fill", .monochrome),
                isDisabled: true
            )
        )
    }

    // MARK: - Internal

    let characterLimit: Int
    let submitComment: (String) -> Bool

    var body: some View {
        let cornerRadius = theme.cornerRadius.value(for: .xxxl)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        HStack(alignment: .center) {
            TextField(
                text: $text,
                prompt: Text("Start chatting"),
                axis: .vertical,
                label: {
                    EmptyView()
                }
            )
            .lineLimit(4)
            .tint(theme.palette.primary.toParraColor())
            .contentMargins(
                .all,
                EdgeInsets(
                    vertical: 4,
                    horizontal: 8
                ),
                for: .automatic
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme.palette.secondaryBackground)
            .applyCornerRadii(
                size: .xxxl,
                from: theme
            )
            .keyboardType(.default)
            .textInputAutocapitalization(.sentences)
            .autocorrectionDisabled(false)
            .focused($isFocused)
            .submitLabel(
                trimmed.isEmpty
                    ? .done : .send
            )
            .onSubmit(of: .text) {
                handleSubmission()
            }

            ZStack(alignment: .center) {
                componentFactory.buildImageButton(
                    config: ParraImageButtonConfig(
                        type: .primary,
                        size: .custom(
                            CGSize(width: 30, height: 30)
                        ),
                        variant: .plain
                    ),
                    content: submitButtonContent,
                    localAttributes: ParraAttributes.ImageButton(
                        normal: ParraAttributes.ImageButton.StatefulAttributes(
                            padding: .zero
                        )
                    )
                ) {
                    handleSubmission()
                }

                if trimmed.count > characterLimit {
                    componentFactory.buildLabel(
                        text: "\(characterLimit - trimmed.count)",
                        localAttributes: ParraAttributes.Label(
                            text: .default(
                                with: .caption,
                                weight: .semibold,
                                color: theme.palette.error.toParraColor(),
                                alignment: .center
                            )
                        )
                    )
                    .padding(.top, 52)
                    .padding(.leading, 9)
                    .padding(.trailing, 12)
                }
            }
        }
        .safeAreaPadding(.horizontal, 10)
        .safeAreaPadding(.top, 10)
        .safeAreaPadding(.bottom, 16)
        .background(theme.palette.primaryBackground)
        .clipShape(
            .rect(
                topLeadingRadius: cornerRadius.topLeading,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: cornerRadius.topTrailing
            )
        )
        .shadow(
            color: theme.palette.secondaryBackground.opacity(0.7),
            radius: 4,
            x: 0,
            y: -2
        )
        .mask(Rectangle().padding(.top, -20))
        .onChange(of: text) { _, newValue in
            if let last = newValue.last, last.isNewline {
                text.removeLast()

                isFocused = false

                return
            }

            let trimmed = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            let isDisabled = !allowSubmission ||
                (trimmed.isEmpty || trimmed.count > characterLimit)

            submitButtonContent = ParraImageButtonContent(
                image: .symbol("arrow.up.circle.fill", .monochrome),
                isDisabled: isDisabled
            )
        }
    }

    // MARK: - Private

    @Binding private var allowSubmission: Bool

    @State private var text = ""
    @State private var submitButtonContent: ParraImageButtonContent
    @FocusState private var isFocused: Bool

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private func handleSubmission() {
        let finalText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let shouldClear = submitComment(finalText)

        if shouldClear {
            text = ""
        }
    }
}
