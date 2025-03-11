//
//  CreatorUpdatePreviewView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/10/25.
//

import SwiftUI

struct CreatorUpdatePreviewView: View {
    // MARK: - Internal

    @StateObject var contentObserver: CreatorUpdateWidget.ContentObserver

    var previewCreatorUpdate: ParraCreatorUpdateAppStub? {
        guard let wipUpdate = contentObserver.creatorUpdate else {
            return nil
        }

        guard let user = authState.user else {
            return nil
        }

        return ParraCreatorUpdateAppStub(
            id: .uuid,
            createdAt: .now,
            updatedAt: .now,
            deletedAt: nil,
            title: wipUpdate.title,
            body: wipUpdate.body,
            sender: ParraCreatorUpdateSenderStub(
                id: user.info.id,
                name: user.info.displayName,
                avatar: user.info.avatar,
                verified: user.info.verified
            ),
            attachments: wipUpdate.attachments.compactMap { attachment in
                switch attachment {
                case .processing:
                    return nil
                case .uploaded(let asset, _, _):
                    return .init(
                        id: asset.id,
                        image: asset
                    )
                case .errored:
                    return nil
                }
            },
            attachmentPaywall: nil
        )
    }

    var body: some View {
        GeometryReader { proxy in
            ScrollView {
                VStack {
                    if let previewCreatorUpdate {
                        CreatorUpdatePreview(
                            creatorUpdate: previewCreatorUpdate,
                            spacing: 8,
                            containerGeometry: proxy
                        )
                        .id("preview-update-unredacted-1")
                    }

                    ForEach(
                        ParraCreatorUpdateAppStub.validStates().indexed(),
                        id: \.element
                    ) { index, redacted in
                        CreatorUpdatePreview(
                            creatorUpdate: redacted.withoutAttachments(),
                            spacing: 8,
                            containerGeometry: proxy
                        )
                        .id("preview-update-redacted-\(index)")
                        .redacted(reason: .placeholder)
                    }
                }
            }
            .background(theme.palette.primaryBackground)
        }
        .navigationBarTitleDisplayMode(.large)
        .navigationTitle("Previewing Post")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if contentObserver.isLoading || isShowingConfirmSchedule {
                    ProgressView()
                } else {
                    Button {
                        isShowingConfirmPublish = true
                    } label: {
                        Image(systemName: "paperplane")
                    }
                }
            }
        }
        .sheet(
            isPresented: $isShowingConfirmSchedule,
            content: {
                NavigationStack {
                    DatePicker(
                        "Schedule your Post",
                        selection: $selectedPublishDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.graphical)
                    .frame(
                        height: 400
                    )
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                createPost(
                                    scheduleAt: selectedPublishDate
                                )
                            } label: {
                                Image(systemName: "paperplane")
                            }
                        }
                    }
                    .navigationTitle("Schedule your Post")
                }
                .presentationDetents([.height(540)])
                .presentationDragIndicator(.visible)
            }
        )
        .confirmationDialog(
            "Publish Post",
            isPresented: $isShowingConfirmPublish,
            titleVisibility: .visible
        ) {
            Button("Publish Now") {
                createPost()
            }

            Button("Schedule for Later") {
                isShowingConfirmSchedule = true
                selectedPublishDate = Date.now
            }

            Button("Cancel", role: .cancel) {}
        } message: {}
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var authState

    @State private var isShowingConfirmPublish = false
    @State private var isShowingConfirmSchedule = false
    @State private var selectedPublishDate = Date.now

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraAlertManager) private var alertManager

    private func createPost(scheduleAt: Date? = nil) {
        let submittingNow = scheduleAt == nil

        let successMessage = if let scheduleAt {
            "Your post will go live in \(scheduleAt.timeFromNowDisplay()). You can edit it or cancel this from the Parra dashboard."
        } else {
            "Your post is live. Edits can be made from the Parra dashboard."
        }

        Task { @MainActor in
            do {
                try await contentObserver.createPost(
                    scheduleAt: scheduleAt
                )

                alertManager.showSuccessToast(
                    title: submittingNow ? "Post Published" : "Post Scheduled",
                    subtitle: successMessage
                )
            } catch {
                alertManager.showErrorToast(
                    title: "",
                    userFacingMessage: "",
                    underlyingError: error
                )
            }
        }
    }
}
