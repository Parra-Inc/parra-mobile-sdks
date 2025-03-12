//
//  CreatorUpdateComposerAttachmentsView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/7/25.
//

import PhotosUI
import SwiftUI

struct CreatorUpdateComposerAttachmentsView: View {
    // MARK: - Internal

    var maxAttachments: Int
    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var body: some View {
        let attachments = contentObserver.creatorUpdate?.attachments ?? []

        ScrollViewReader { scrollView in
            ScrollView(.horizontal) {
                HStack(spacing: 12) {
                    ForEach(attachments, id: \.self) { attachment in
                        CreatorUpdateComposerAttachmentView(
                            attachment: attachment
                        ) {
                            if let asset = attachment.asset {
                                currentPreviewAsset = asset
                                isShowingFullScreen = true
                            }
                        }
                    }

                    if attachments.count < maxAttachments {
                        Button {
                            showingPhotoPicker = true
                        } label: {
                            Image(systemName: "plus")
                        }
                        .id("add-more-button")
                        .contentShape(.rect)
                        .frame(
                            width: 100,
                            height: 100,
                            alignment: .center
                        )
                        .background(
                            theme.palette.secondaryBackground
                        )
                    }
                }
            }
            .scrollIndicators(.never)
            .onChange(of: selectedPhoto) {
                guard let selectedPhoto else {
                    return
                }

                Task { @MainActor in
                    self.selectedPhoto = nil

                    await contentObserver.attachImage(
                        from: selectedPhoto
                    ) {
                        Task { @MainActor in
                            // enough for the photo picker to dismiss
                            try await Task.sleep(for: 0.3)

                            withAnimation {
                                scrollView.scrollTo("add-more-button", anchor: .trailing)
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $isShowingFullScreen) {
            let attachments = contentObserver.creatorUpdate?.attachments ?? []
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
            isPresented: $showingPhotoPicker,
            selection: $selectedPhoto,
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
    }

    // MARK: - Private

    @State private var showingPhotoPicker = false
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var isShowingFullScreen = false
    @State private var currentPreviewAsset: ParraImageAsset?

    @Environment(\.parraTheme) private var theme
}
