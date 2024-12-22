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
        submitComment: @escaping (String) async throws -> Void
    ) {
        self.submitComment = submitComment
        self._submitButtonContent = State(
            initialValue: SubmitState.noContent.content
        )
    }

    // MARK: - Internal

    enum SubmitState: Equatable {
        case noContent
        case content(String)
        case submitting(String)
        case error(String, ParraError)

        // MARK: - Internal

        var currentText: String {
            switch self {
            case .noContent:
                return ""
            case .content(let content):
                return content
            case .submitting(let content):
                return content
            case .error(let content, _):
                return content
            }
        }

        var content: ParraImageButtonContent {
            switch self {
            case .noContent, .error:
                ParraImageButtonContent(
                    image: .symbol("arrow.up.circle.fill", .monochrome),
                    isDisabled: true
                )
            case .content(let content):
                ParraImageButtonContent(
                    image: .symbol("arrow.up.circle.fill", .monochrome),
                    isDisabled: content.isEmpty
                )
            case .submitting:
                ParraImageButtonContent(
                    image: .symbol("arrow.up.circle.fill", .monochrome),
                    isDisabled: true
                )
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
            case (.submitting(let lhs), .submitting(let rhs)):
                return lhs == rhs
            case (.error(let lc, let le), .error(let rc, let re)):
                return lc == rc && le.localizedDescription == re.localizedDescription
            default:
                return false
            }
        }
    }

    let submitComment: (String) async throws -> Void

    var body: some View {
        VStack {
            HStack(alignment: .center) {
                componentFactory.buildTextInput(
                    config: ParraTextInputConfig(
                        resizeWhenHelperMessageIsVisible: true,
                        keyboardType: .default,
                        textInputAutocapitalization: .sentences,
                        autocorrectionDisabled: false,
                        shouldAutoFocus: false
                    ),
                    content: ParraTextInputContent(
                        title: nil,
                        defaultText: currentState.currentText,
                        placeholder: "Start chatting",
                        helper: nil,
                        errorMessage: errorMessage,
                        textChanged: { newText in

                            // TODO: Character limit should be 250
                            // TODO: Error should be for too long or too short

                            if let newText, !newText.isEmpty {
                                currentState = .content(newText)
                            } else {
                                currentState = .noContent
                            }

//                            errorMessage = newText
                        }
                    ),
                    localAttributes: ParraAttributes.TextInput(
                        padding: .zero,
                        background: theme.palette.primaryBackground
                    )
                )

                if case .submitting = currentState {
                    ProgressView()
                } else {
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
            }
        }
        .frame(
            maxWidth: .infinity
        )
        .padding(.bottom)
        .safeAreaPadding([.bottom, .horizontal])
        .onChange(of: currentState) { _, newValue in
            submitButtonContent = newValue.content
        }
    }

    // MARK: - Private

    @State private var currentState: SubmitState = .noContent
    @State private var errorMessage: String?
    @State private var submitButtonContent: ParraImageButtonContent

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private func handleSubmission() {
        Task { @MainActor in
            let text = currentState.currentText

            do {
                currentState = .submitting(text)

                try await submitComment(text)

                currentState = .noContent
            } catch {
                currentState = .error(text, ParraError.system(error))
            }
        }
    }
}
