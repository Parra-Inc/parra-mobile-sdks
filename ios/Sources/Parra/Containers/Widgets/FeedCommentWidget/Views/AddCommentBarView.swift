//
//  AddCommentBarView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import SwiftUI

private let characterLimit: Int = 250

struct AddCommentBarView: View {
    // MARK: - Lifecycle

    init(
        submitComment: @escaping (String) -> Void
    ) {
        self.submitComment = submitComment
        self._submitButtonContent = State(
            initialValue: ParraImageButtonContent(
                image: .symbol("arrow.up.circle.fill", .monochrome),
                isDisabled: true
            )
        )
    }

    // MARK: - Internal

    enum SubmitState: Equatable {
        case noContent
        case content(String)

        // MARK: - Internal

        var currentText: String {
            switch self {
            case .noContent:
                return ""
            case .content(let content):
                return content
            }
        }

        static func == (
            lhs: AddCommentBarView.SubmitState,
            rhs: AddCommentBarView.SubmitState
        ) -> Bool {
            switch (lhs, rhs) {
            case (.noContent, .noContent):
                return true
            case (.content(let lhs), .content(let rhs)):
                return lhs == rhs
            default:
                return false
            }
        }
    }

    let submitComment: (String) -> Void

    // TODO: Character limit should be 250
    // TODO: Error should be for too long or too short

    var body: some View {
        let cornerRadius = theme.cornerRadius.value(for: .xxxl)

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
            .submitLabel(.send)
            .onSubmit(of: .text) {
                handleSubmission()

                isFocused = false
            }

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
        .onChange(of: text) { _, newValue in
            let trimmed = newValue.trimmingCharacters(
                in: .whitespacesAndNewlines
            )

            submitButtonContent = ParraImageButtonContent(
                image: .symbol("arrow.up.circle.fill", .monochrome),
                isDisabled: trimmed.isEmpty
            )
        }
    }

    // MARK: - Private

    @State private var text = ""
    @State private var submitButtonContent: ParraImageButtonContent
    @FocusState private var isFocused: Bool

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private func handleSubmission() {
        let finalText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        submitComment(finalText)

        text = ""
    }
}
