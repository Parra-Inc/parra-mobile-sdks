//
//  CreatorUpdateComposerFieldsView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/12/25.
//

import SwiftUI

struct CreatorUpdateComposerFieldsView: View {
    // MARK: - Internal

    enum Field: Hashable {
        case title
        case body
    }

    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var textEditorttributes: ParraAttributes.TextEditor {
        componentFactory.attributeProvider.textEditorAttributes(
            config: .init(
                textInputAutocapitalization: .sentences,
                autocorrectionDisabled: false,
                shouldAutoFocus: false
            ),
            localAttributes: nil,
            theme: theme
        )
    }

    var body: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                componentFactory.buildLabel(
                    text: "Title",
                    localAttributes: .defaultInputTitle(for: theme)
                )

                componentFactory.buildTextInput(
                    config: ParraTextInputConfig(
                        shouldAutoFocus: false
                    ),
                    content: .init(
                        defaultText: contentObserver.creatorUpdate?.title,
                        placeholder: ParraLabelContent(text: ""),
                        textChanged: { text in
                            contentObserver.creatorUpdate?.title = text ?? ""
                        }
                    ),
                    localAttributes: ParraAttributes.TextInput(
                        padding: .zero,
                        textInputAutocapitalization: .sentences,
                        autocorrectionDisabled: false
                    )
                )
                .focused($focusedField, equals: .title)
                .submitLabel(.next)
                .onSubmit {
                    focusedField = .body
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                componentFactory.buildLabel(
                    text: "Body",
                    localAttributes: .defaultInputTitle(for: theme)
                )

                TextEditor(
                    text: Binding<String>(
                        get: {
                            contentObserver.creatorUpdate?.body ?? ""
                        },
                        set: { newValue in
                            contentObserver.creatorUpdate?.body = newValue
                        }
                    )
                )
                .applyTextEditorAttributes(textEditorttributes, using: theme)
                .focused($focusedField, equals: .body)
                .submitLabel(.continue)
            }
        }
        .padding(.bottom, 12)
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}
