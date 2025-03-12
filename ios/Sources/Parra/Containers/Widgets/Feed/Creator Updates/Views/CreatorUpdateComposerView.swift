//
//  CreatorUpdateComposerView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/25.
//

import SwiftUI

private let maxAttachments = 10
private let logger = Logger()

struct CreatorUpdateComposerView: View {
    // MARK: - Lifecycle

    init(
        creatorUpdate: NewCreatorUpdate,
        contentObserver: StateObject<CreatorUpdateWidget.ContentObserver>
    ) {
        self.creatorUpdate = creatorUpdate
        self._contentObserver = contentObserver
    }

    // MARK: - Internal

    enum Field: Hashable {
        case title
        case body
    }

    var creatorUpdate: NewCreatorUpdate
    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                badgeBar

                inputFields

                attachments

                visibility
            }
            .contentMargins(20, for: .scrollContent)
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)

            footer
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .background(theme.palette.primaryBackground)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("New Post")
    }

    var shouldDisablePreviewButton: Bool {
        creatorUpdate.title
            .trimmingCharacters(
                in: .whitespacesAndNewlines
            ).isEmpty || creatorUpdate.body.trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            .isEmpty || isLoading
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var badgeBar: some View {
        HStack {
            CreatorUpdateTagBadge(
                title: creatorUpdate.selectedTemplate.name,
                style: .secondary
            )

            withContent(content: creatorUpdate.topic) { content in
                CreatorUpdateTagBadge(
                    title: content.displayName,
                    icon: "number",
                    style: .secondary
                )
            }

            Spacer()
        }
        .padding(.bottom, 16)
    }

    private var textEditorAttributes: ParraAttributes.TextEditor {
        ParraAttributes.TextEditor(
            titleLabel: .default(with: .body),
            padding: .zero,
            textInputAutocapitalization: .sentences,
            autocorrectionDisabled: false
        )
    }

//    private var textEditorContent: ParraTextEditorContent {
//        ParraTextEditorContent(
//            title: ParraLabelContent(text: ""),
//            defaultText: creatorUpdate.body,
//            placeholder: ParraLabelContent(text: "Body"),
//            helper: ParraLabelContent(text: ""),
//            textChanged: { text in
//
//            }
//        )
//    }

    @ViewBuilder private var inputFields: some View {
        VStack(alignment: .leading) {
            VStack(alignment: .leading, spacing: 0) {
                componentFactory.buildLabel(
                    text: "Title",
                    localAttributes: .defaultInputTitle(for: theme)
                )

//                TextField(text: <#T##Binding<String>#>, label: <#T##() -> View#>)
                componentFactory.buildTextInput(
                    config: ParraTextInputConfig(
                        shouldAutoFocus: false
                    ),
                    content: .init(
                        defaultText: creatorUpdate.title,
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

                let attributes = componentFactory.attributeProvider.textEditorAttributes(
                    config: .default,
                    localAttributes: nil,
                    theme: theme
                )

                // Can't currently figure out why but using the text editor
                // component componentFactory.buildTextEditor is causing this
                // https://console.firebase.google.com/u/0/project/kb-app-f1338/crashlytics/app/ios:com.kurt-benkert.kb-ios/issues/e08c202a8fbcf80ab06cdf8acef2c4b9?time=last-seven-days&types=crash&sessionEventKey=af1ccae153c649228675152425179952_2059485690314412986
                // crash

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
                .applyTextEditorAttributes(attributes, using: theme)
                .focused($focusedField, equals: .body)
                .submitLabel(.continue)
            }
        }
        .padding(.bottom, 12)
    }

    @ViewBuilder private var attachments: some View {
        VStack(alignment: .leading) {
            HStack {
                componentFactory.buildLabel(
                    text: "Attachments",
                    localAttributes: .default(
                        with: .headline,
                        alignment: .leading
                    )
                )

                Spacer()

                if let attachments = contentObserver.creatorUpdate?
                    .attachments, !attachments.isEmpty
                {
                    componentFactory.buildLabel(
                        text: "\(attachments.count)/\(maxAttachments)",
                        localAttributes: .default(
                            with: .caption,
                            alignment: .trailing
                        )
                    )
                }
            }

            CreatorUpdateComposerAttachmentsView(
                maxAttachments: maxAttachments,
                contentObserver: contentObserver
            )
        }
        .padding(.bottom, 16)
    }

    @ViewBuilder private var visibility: some View {
        VStack(alignment: .leading) {
            componentFactory.buildLabel(
                text: "Visibility",
                localAttributes: .default(
                    with: .headline,
                    alignment: .leading
                )
            )

            postVisibility

            if !creatorUpdate.attachments.isEmpty {
                attachmentVisibility
                    .padding(.top, 8)
            }
        }
    }

    @ViewBuilder private var postVisibility: some View {
        CreatorUpdateVisibilitySettingView(
            currentVisibility: .init(
                get: {
                    return contentObserver.creatorUpdate?.visibility.postVisibility
                        ?? creatorUpdate.selectedTemplate.visibility.postVisibility
                },
                set: { newValue in
                    logger.debug("Updated post visibility", [
                        "visibility": newValue.rawValue
                    ])

                    contentObserver.creatorUpdate?.visibility
                        .postVisibility = newValue
                }
            ),
            title: "Who can see this post?"
        )
    }

    @ViewBuilder private var attachmentVisibility: some View {
        CreatorUpdateVisibilitySettingView(
            currentVisibility: .init(
                get: {
                    return contentObserver.creatorUpdate?.visibility
                        .attachmentVisibility
                        ?? creatorUpdate.selectedTemplate.visibility
                        .attachmentVisibility ?? .public
                },
                set: { newValue in
                    logger.debug("Updated attachment visibility", [
                        "visibility": newValue.rawValue
                    ])

                    contentObserver.creatorUpdate?.visibility
                        .attachmentVisibility = newValue
                }
            ),
            title: "Who can see attachments?"
        )
    }

    @ViewBuilder private var footer: some View {
        WidgetFooter(
            primaryActionBuilder: {
                NavigationLink {
                    CreatorUpdatePreviewView(
                        contentObserver: contentObserver
                    )
                } label: {
                    let attributes = componentFactory.attributeProvider
                        .containedButtonAttributes(
                            config: ParraTextButtonConfig(
                                type: .primary,
                                size: .large,
                                isMaxWidth: true
                            ),
                            localAttributes: ParraAttributes.ContainedButton(
                                normal: ParraAttributes.ContainedButton
                                    .StatefulAttributes(
                                        label: ParraAttributes.Label(
                                            cornerRadius: .lg,
                                            padding: .xl,
                                            background: shouldDisablePreviewButton ? theme
                                                .palette.primary
                                                .toParraColor()
                                                .opacity(
                                                    0.6
                                                ) : theme.palette.primary
                                                .toParraColor(),
                                            frame: .flexible(
                                                FlexibleFrameAttributes(
                                                    maxWidth: .infinity
                                                )
                                            )
                                        )
                                    )
                            ),
                            theme: theme
                        )
                    componentFactory.buildLabel(
                        content: ParraLabelContent(
                            text: "Preview Post",
                            isLoading: isLoading
                        ),
                        localAttributes: attributes.normal.label
                    )
                    .safeAreaPadding(.horizontal)
                }
                .disabled(shouldDisablePreviewButton)
            },
            secondaryActionBuilder: {
                // Just to hide branding here. This is a creator only screen.
                EmptyView()
            },
            contentPadding: .padding(vertical: 12)
        )
    }

    private var isLoading: Bool {
        let attachments = contentObserver.creatorUpdate?.attachments ?? []

        if attachments.isEmpty {
            return false
        }

        for attachment in attachments {
            switch attachment {
            case .processing:
                return true
            default:
                continue
            }
        }

        return false
    }
}

private let primaryColor = Color(red: 255 / 255.0, green: 201 / 255.0, blue: 6 / 255.0)

#Preview {
    ParraContainerPreview<CreatorUpdateWidget>(
        config: .default,
        theme: .default,
        authState: .authenticatedPreview
    ) { parra, _, config in

        NavigationStack {
            CreatorUpdateComposerView(
                creatorUpdate: NewCreatorUpdate(
                    template: CreatorUpdateTemplate(
                        id: .uuid,
                        createdAt: .now.daysAgo(1),
                        updatedAt: .now.daysAgo(1),
                        deletedAt: nil,
                        name: "",
                        tenantId: .uuid,
                        senderId: .uuid,
                        feedViewId: nil,
                        notificationTemplateId: nil,
                        topic: .init(nil),
                        title: nil,
                        body: nil,
                        visibility: .init(
                            entitlementId: nil,
                            paywallContext: nil,
                            postVisibility: .public,
                            attachmentVisibility: .public
                        )
                    )
                ),
                contentObserver: .init(
                    wrappedValue: CreatorUpdateWidget.ContentObserver(
                        initialParams: .init(
                            feedId: .uuid,
                            config: .default,
                            templates: [],
                            api: parra.parraInternal.api
                        )
                    )
                )
            )
        }
    }
}
