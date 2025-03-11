//
//  CreatorUpdateComposerView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/25.
//

import SwiftUI

struct CreatorUpdateComposerView: View {
    // MARK: - Lifecycle

    init(
        creatorUpdate: NewCreatorUpdate,
        contentObserver: StateObject<CreatorUpdateWidget.ContentObserver>
    ) {
        self.creatorUpdate = creatorUpdate
        self._contentObserver = contentObserver

        let visibility = creatorUpdate.visibility

        self._postVisibility = State(
            initialValue: visibility.postVisibility
        )

        self._attachmentVisibility = State(
            initialValue: visibility.attachmentVisibility ?? visibility.postVisibility
        )
    }

    // MARK: - Internal

    enum Field: Hashable {
        case title
        case body
    }

    var creatorUpdate: NewCreatorUpdate
    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var isLoading: Bool {
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

    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading) {
                    withContent(content: creatorUpdate.topic) { content in
                        CreatorUpdateTagBadge(
                            title: content.rawValue,
                            icon: "number",
                            style: .secondary
                        )
                        .padding(.bottom, 8)
                    }

                    componentFactory.buildTextInput(
                        config: ParraTextInputConfig(
                            shouldAutoFocus: false
                        ),
                        content: .init(
                            defaultText: creatorUpdate.title,
                            placeholder: ParraLabelContent(text: "Title"),
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
                    .padding(0)

                    componentFactory.buildTextEditor(
                        config: .init(
                            shouldAutoFocus: false
                        ),
                        content: .init(
                            defaultText: creatorUpdate.body,
                            placeholder: ParraLabelContent(text: "Body"),
                            textChanged: { text in
                                contentObserver.creatorUpdate?.body = text ?? ""
                            }
                        ),
                        localAttributes: ParraAttributes.TextEditor(
                            padding: .zero,
                            textInputAutocapitalization: .sentences,
                            autocorrectionDisabled: false
                        )
                    )
                    .focused($focusedField, equals: .body)
                    .submitLabel(.continue)

                    HStack {
                        componentFactory.buildLabel(
                            text: "Who can see this post?",
                            localAttributes: .default(with: .callout)
                        )

                        Spacer()

                        Picker(
                            "Who can see this post?",
                            selection: $postVisibility
                        ) {
                            ForEach(CreatorUpdateVisibilityType.allCases) { type in
                                let isCurrent = type == creatorUpdate.selectedTemplate
                                    .visibility.postVisibility

                                let title = isCurrent ? "\(type.composerName) (Default)" :
                                    type.composerName

                                Button(title) {
                                    postVisibility = type
                                    contentObserver.creatorUpdate?.visibility
                                        .postVisibility = type
                                }
                                .tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                    }

                    componentFactory.buildLabel(
                        text: "Attachments",
                        localAttributes: .default(with: .headline, alignment: .leading)
                    )
                    .padding(.top, 32)

                    CreatorUpdateComposerAttachmentsView(
                        contentObserver: contentObserver
                    )

                    if !creatorUpdate.attachments.isEmpty {
                        HStack {
                            componentFactory.buildLabel(
                                text: "Who can see these attachments?",
                                localAttributes: .default(with: .callout)
                            )

                            Spacer()

                            Picker(
                                "Who can see these attachments?",
                                selection: $attachmentVisibility
                            ) {
                                ForEach(CreatorUpdateVisibilityType.allCases) { type in
                                    let isCurrent = type == creatorUpdate.selectedTemplate
                                        .visibility.attachmentVisibility

                                    let title = isCurrent ?
                                        "\(type.composerName) (Default)" : type
                                        .composerName

                                    Button(title) {
                                        attachmentVisibility = type
                                        contentObserver.creatorUpdate?.visibility
                                            .attachmentVisibility = type
                                    }
                                    .tag(type)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding()
            }
            .scrollContentBackground(.hidden)
            .scrollDismissesKeyboard(.immediately)

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
                                    size: .medium,
                                    isMaxWidth: true
                                ),
                                localAttributes: ParraAttributes.ContainedButton(
                                    normal: ParraAttributes.ContainedButton
                                        .StatefulAttributes(
                                            label: ParraAttributes.Label(
                                                cornerRadius: .lg,
                                                padding: .xl,
                                                background: theme.palette.primary
                                                    .toParraColor(
                                                    ),
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
                    .disabled(
                        creatorUpdate.title.isEmpty || creatorUpdate.body
                            .isEmpty || isLoading
                    )
                },
                secondaryActionBuilder: {
                    // Just to hide branding here. This is a creator only screen.
                    EmptyView()
                },
                contentPadding: .padding(vertical: 12)
            )
        }
        .background(theme.palette.primaryBackground)
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("New \(creatorUpdate.selectedTemplate.name) Post")
    }

    // MARK: - Private

    @FocusState private var focusedField: Field?

    @State private var postVisibility: CreatorUpdateVisibilityType
    @State private var attachmentVisibility: CreatorUpdateVisibilityType

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
}

private let primaryColor = Color(red: 255 / 255.0, green: 201 / 255.0, blue: 6 / 255.0)

let theme = ParraTheme(
    lightPalette: ParraColorPalette(
        primary: ParraColorSwatch(
            primary: primaryColor,
            name: "Primary"
        ),
        secondary: ParraColorSwatch(
            primary: .black,
            name: "Secondary"
        ),
        primaryBackground: Color(red: 246 / 255.0, green: 243 / 255.0, blue: 233 / 255.0),
        secondaryBackground: .white,
        primaryText: ParraColorSwatch(
            primary: Color(red: 60 / 255.0, green: 60 / 255.0, blue: 67 / 255.0),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(red: 17 / 255.0, green: 24 / 255.0, blue: 39 / 255.0),
            name: "Secondary Text"
        ),
        primarySeparator: ParraColorSwatch(
            primary: Color(red: 229 / 255.0, green: 231 / 255.0, blue: 235 / 255.0),
            name: "Primary Separator"
        ),
        secondarySeparator: ParraColorSwatch(
            primary: Color(red: 198 / 255.0, green: 198 / 255.0, blue: 198 / 255.0),
            name: "Secondary Separator"
        ),
        primaryChipText: ParraColorSwatch(
            primary: Color(UIColor.systemBlue),
            name: "Primary Chip Text"
        ).shade700.toSwatch(),
        secondaryChipText: ParraColorSwatch(
            primary: ParraColorSwatch.gray.shade800,
            name: "Secondary Chip Text"
        ),
        primaryChipBackground: ParraColorSwatch(
            primary: Color(UIColor.systemBlue),
            name: "Primary Chip Background"
        ).shade400.toSwatch(),
        secondaryChipBackground: ParraColorSwatch(
            primary: ParraColorSwatch.zinc.shade200,
            name: "Secondary Chip Background"
        ),
        error: ParraColorSwatch(
            primary: Color(red: 225 / 255.0, green: 82 / 255.0, blue: 65 / 255.0),
            name: "Error"
        ),
        warning: ParraColorSwatch(
            primary: Color(red: 253 / 255.0, green: 169 / 255.0, blue: 66 / 255.0),
            name: "Warning"
        ),
        info: ParraColorSwatch(
            primary: Color(red: 38 / 255.0, green: 139 / 255.0, blue: 210 / 255.0),
            name: "Info"
        ),
        success: ParraColorSwatch(primary: .green, name: "Success")
    ),
    darkPalette: ParraColorPalette(
        primary: ParraColorSwatch(
            primary: primaryColor,
            name: "Primary"
        ),
        secondary: ParraColorSwatch(
            primary: .white,
            name: "Secondary"
        ),
        primaryBackground: Color(red: 54 / 255.0, green: 65 / 255.0, blue: 85 / 255.0),
        secondaryBackground: Color(red: 26 / 255.0, green: 31 / 255.0, blue: 41 / 255.0),
        primaryText: ParraColorSwatch(
            primary: Color(red: 235 / 255.0, green: 237 / 255.0, blue: 240 / 255.0),
            name: "Primary Text"
        ),
        secondaryText: ParraColorSwatch(
            primary: Color(red: 187 / 255.0, green: 189 / 255.0, blue: 191 / 255.0),
            name: "Secondary Text"
        ),
        primarySeparator: ParraColorSwatch(
            primary: Color(red: 44 / 255.0, green: 55 / 255.0, blue: 75 / 255.0),
            name: "Primary Separator"
        ),
        secondarySeparator: ParraColorSwatch(
            primary: Color(red: 71 / 255.0, green: 76 / 255.0, blue: 86 / 255.0),
            name: "Secondary Separator"
        ),
        primaryChipText: ParraColorSwatch(
            primary: ParraColorSwatch.gray.shade50,
            name: "Primary Chip Text"
        ),
        secondaryChipText: ParraColorSwatch(
            primary: ParraColorSwatch.gray.shade50,
            name: "Secondary Chip Text"
        ),
        primaryChipBackground: ParraColorSwatch(
            primary: Color(UIColor.systemBlue).opacity(0.65),
            name: "Primary Chip Background"
        ).shade500.toSwatch(),
        secondaryChipBackground: ParraColorSwatch(
            primary: ParraColorSwatch.zinc.shade600,
            name: "Secondary Chip Background"
        ),
        error: ParraColorSwatch(
            primary: Color(red: 225 / 255.0, green: 82 / 255.0, blue: 65 / 255.0),
            name: "Error"
        ),
        warning: ParraColorSwatch(
            primary: Color(red: 253 / 255.0, green: 169 / 255.0, blue: 66 / 255.0),
            name: "Warning"
        ),
        info: ParraColorSwatch(
            primary: Color(red: 38 / 255.0, green: 139 / 255.0, blue: 210 / 255.0),
            name: "Info"
        ),
        success: ParraColorSwatch(primary: .green, name: "Success")
    )
)

#Preview {
    ParraContainerPreview<CreatorUpdateWidget>(
        config: .default,
        theme: theme,
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
                        topic: nil,
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
