//
//  AddCommentBarView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/18/24.
//

import PhotosUI
import SwiftUI

private let logger = Logger()

struct AddCommentBarView: View {
    // MARK: - Lifecycle

    init(
        allowSubmission: Binding<Bool>,
        characterLimit: Int = 250,
        allowAttachments: Bool = false,
        submitComment: @escaping (String, [Attachment]) -> Bool
    ) {
        self._allowSubmission = allowSubmission
        self.characterLimit = characterLimit
        self.submitComment = submitComment
        self.allowAttachments = allowAttachments
        self._submitButtonContent = State(
            initialValue: ParraImageButtonContent(
                image: .symbol("arrow.up.circle.fill", .monochrome),
                isDisabled: true
            )
        )
        self._attachmentButtonContent = State(
            initialValue: ParraImageButtonContent(
                image: .symbol("photo.badge.plus.fill", .monochrome),
                isDisabled: !allowAttachments
            )
        )
    }

    // MARK: - Internal

    let characterLimit: Int
    let allowAttachments: Bool
    let submitComment: (String, [Attachment]) -> Bool

    var body: some View {
        let cornerRadius = theme.cornerRadius.value(for: .xxxl)
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)

        VStack(spacing: 16) {
            if !attachmentManager.attachments.isEmpty {
                attachmentsView
            }

            HStack(alignment: .center) {
                if allowAttachments {
                    attachmentButton
                }

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
        .sheet(isPresented: $isShowingFullScreen) {
            let attachments = attachmentManager.attachments
            let assets: [ParraImageAsset] = attachments.compactMap { attachment in
                switch attachment {
                case .processing, .errored:
                    return nil
                case .uploaded(let asset, _, _):
                    return asset
                }
            }

            NavigationStack {
                FullScreenGalleryView(
                    photos: assets,
                    selectedPhoto: $currentPreviewAsset
                )
            }
            .transition(.opacity)
        }
        .photosPicker(
            isPresented: $attachmentManager.showingPhotoPicker,
            selection: $attachmentManager.selectedPhotos,
            maxSelectionCount: 10,
            matching: .all(
                of: [
                    .images,
                    .not(
                        .any(
                            of: [
                                .livePhotos, .depthEffectPhotos,
                                .panoramas, .bursts
                            ]
                        )
                    )
                ]
            ),
            preferredItemEncoding: .compatible,
            // IMPORTANT: A photo library must be provided in order for the
            // `itemIdentifier` to be set on the user's selections.
            photoLibrary: .shared()
        )
        .onChange(of: attachmentManager.attachments) { _, _ in
            withAnimation {
                validate()
            }
        }
        .onChange(of: text) { _, newValue in
            if let last = newValue.last, last.isNewline {
                text.removeLast()

                isFocused = false

                return
            }

            validate()
        }
    }

    // MARK: - Private

    @Binding private var allowSubmission: Bool

    @State private var attachmentManager = AttachmentManager(
        group: "chat-message-attachment"
    )

    @State private var text = ""
    @State private var submitButtonContent: ParraImageButtonContent
    @State private var attachmentButtonContent: ParraImageButtonContent
    @State private var isShowingFullScreen = false
    @State private var currentPreviewAsset: ParraImageAsset?

    @FocusState private var isFocused: Bool

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    private var attachmentsView: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 12) {
                ForEach(
                    attachmentManager.attachments,
                    id: \.self
                ) { attachment in
                    CreatorUpdateComposerAttachmentView(
                        attachment: attachment
                    ) {
                        if let asset = attachment.asset {
                            currentPreviewAsset = asset
                            isShowingFullScreen = true
                        }
                    }
                    .applyCornerRadii(size: .lg, from: theme)
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation {
                                attachmentManager.removeAttachment(attachment)
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .renderingMode(.template)
                                .foregroundStyle(.white, .gray)
                                .contentShape(.circle)
                        }
                        .buttonStyle(.plain)
                        .contentShape(.circle)
                        .clipShape(.circle)
                        .applyBorder(
                            .init(width: 1.0, color: .white),
                            with: .full,
                            from: theme
                        )
                        .padding(5)
                    }
                }
            }
        }
        .scrollIndicators(.never)
        .padding(.top, 12)
    }

    private var attachmentButton: some View {
        componentFactory.buildImageButton(
            config: ParraImageButtonConfig(
                type: .secondary,
                size: .custom(
                    CGSize(width: 30, height: 30)
                ),
                variant: .plain
            ),
            content: attachmentButtonContent,
            localAttributes: ParraAttributes.ImageButton(
                normal: ParraAttributes.ImageButton.StatefulAttributes(
                    padding: .zero
                )
            )
        ) {
            attachmentManager.showingPhotoPicker = true
        }
        .if(!attachmentManager.selectedPhotos.isEmpty, renderer: { image in
            image.badge(attachmentManager.selectedPhotos.count)
        })
    }

    private func validate() {
        let trimmed = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let allAttachmentsProcessed = attachmentManager.attachments
            .allSatisfy { attachment in
                switch attachment {
                case .uploaded:
                    return true
                default:
                    return false
                }
            }

        let textValid = !trimmed.isEmpty && trimmed.count <= characterLimit

        let isEnabled = if allowSubmission {
            if attachmentManager.attachments.isEmpty {
                textValid
            } else {
                allAttachmentsProcessed
            }
        } else {
            false
        }

        submitButtonContent = ParraImageButtonContent(
            image: .symbol("arrow.up.circle.fill", .monochrome),
            isDisabled: !isEnabled
        )
    }

    private func handleSubmission() {
        let finalText = text.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        let attachments = attachmentManager.attachments.compactMap {
            switch $0 {
            case .uploaded(let asset, _, _):
                return Attachment.image(asset)
            default:
                return nil
            }
        }

        let shouldClear = submitComment(
            finalText,
            attachments
        )

        if shouldClear {
            withAnimation {
                text = ""
                attachmentManager.clear()
            }
        }
    }
}
