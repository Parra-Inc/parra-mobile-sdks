//
//  CreatorUpdatePreviewView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/10/25.
//

import SwiftUI

private let logger = Logger()

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
            VStack {
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

                WidgetFooter(
                    primaryActionBuilder: {
                        componentFactory.buildContainedButton(
                            config: ParraTextButtonConfig(
                                type: .primary,
                                size: .medium,
                                isMaxWidth: true
                            ),
                            content: ParraTextButtonContent(
                                text: "Publish Now",
                                isDisabled: isShowingSchedulePicker || contentObserver
                                    .isLoading,
                                isLoading: contentObserver.isLoading
                            ),
                            localAttributes: ParraAttributes.ContainedButton(
                                normal: .init(
                                    padding: .zero
                                )
                            )
                        ) {
                            logger.debug("Publish now")

                            isShowingConfirmPublish = true
                        }
                    },
                    secondaryActionBuilder: {
                        componentFactory.buildPlainButton(
                            config: ParraTextButtonConfig(
                                type: .primary,
                                size: .small,
                                isMaxWidth: true
                            ),
                            text: "Schedule for Later",
                            localAttributes: ParraAttributes.PlainButton(
                                normal: .init(
                                    padding: .zero
                                )
                            )
                        ) {
                            logger.debug("Publish now")

                            isShowingSchedulePicker = true
                            selectedPublishDate = Date.now
                        }
                    },
                    contentPadding: .init(vertical: 16, horizontal: 16),
                    actionSpacing: 10
                )
            }
        }
        .renderToast(toast: $alertManager.currentToast)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Preview")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if contentObserver.isLoading {
                    ProgressView()
                }
            }
        }
        .sheet(
            isPresented: $isShowingSchedulePicker,
            content: {
                NavigationStack {
                    VStack {
                        DatePicker(
                            "Schedule Post",
                            selection: $selectedPublishDate,
                            // 5 minutes from now through 1 year from now.
                            in: Date.now
                                .addingTimeInterval(300) ... Date.now
                                .daysFromNow(365),
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.graphical)
                        .frame(
                            height: 400
                        )
                        .padding(.bottom, 32)

                        Spacer()

                        WidgetFooter(
                            primaryActionBuilder: {
                                componentFactory.buildContainedButton(
                                    config: ParraTextButtonConfig(
                                        type: .primary,
                                        size: .medium,
                                        isMaxWidth: true
                                    ),
                                    content: ParraTextButtonContent(
                                        text: "Confirm Scheduled Post",
                                        isLoading: contentObserver.isLoading
                                    )
                                ) {
                                    isShowingSchedulePicker = false

                                    createPost(scheduleAt: selectedPublishDate)
                                }
                            },
                            secondaryActionBuilder: {
                                // Just to hide branding here. This is a creator only screen.
                                EmptyView()
                            }
                        )
                    }
                    .navigationTitle("Schedule Post")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .presentationDetents([.height(600)])
                .presentationDragIndicator(.visible)
            }
        )
        .alert(
            "Publish Post",
            isPresented: $isShowingConfirmPublish,
            actions: {
                Button("Publish", role: .destructive) {
                    createPost()
                }

                Button("Cancel", role: .cancel) {}
            },
            message: {
                Text(
                    "When you publish your post, it will be visible to your users immediately."
                )
            }
        )
    }

    // MARK: - Private

    @Environment(\.parra) private var parra
    @Environment(\.parraAuthState) private var authState
    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    @State private var alertManager: ParraAlertManager = .shared
    @State private var isShowingConfirmPublish = false
    @State private var isShowingSchedulePicker = false
    @State private var selectedPublishDate = Date.now

    private func createPost(scheduleAt: Date? = nil) {
        let submittingNow = scheduleAt == nil

        let date = selectedPublishDate.formatted(
            date: .complete,
            time: .omitted
        )

        let time = selectedPublishDate.formatted(
            date: .omitted,
            time: .complete
        )

        let successMessage = if submittingNow {
            "Your post is live. Edits can be made from the Parra dashboard."
        } else {
            "Your post will go live on \(date) at \(time). You can edit it or cancel it from the Parra dashboard."
        }

        let errorTitle = submittingNow ? "Error Publishing Post" : "Error Scheduling Post"

        let defaultError = { (error: Error) in
            alertManager.showErrorToast(
                title: errorTitle,
                userFacingMessage: "Try again and report this issue if it persists.",
                underlyingError: error
            )
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
            } catch let error as ParraError {
                if case .networkError(_, let response, _) = error {
                    if response.statusCode == 403 {
                        alertManager.showErrorToast(
                            title: errorTitle,
                            userFacingMessage: "This account is not authorized to create posts.",
                            underlyingError: error
                        )
                    } else {
                        defaultError(error)
                    }
                } else {
                    defaultError(error)
                }
            } catch {
                defaultError(error)
            }
        }
    }
}
