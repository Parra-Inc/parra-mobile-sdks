//
//  AppReleaseContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseContent: ParraContainerContent, Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ newInstalledAppVersion: ParraNewInstalledVersionInfo,
        emptyStateContent: ParraEmptyStateContent
    ) {
        self.id = newInstalledAppVersion.release.id
        self.title = ParraLabelContent(
            text: newInstalledAppVersion.configuration.title
        )
        self.subtitle = ParraLabelContent(
            text: newInstalledAppVersion.release.name
        )
        self.version = ParraLabelContent(
            text: newInstalledAppVersion.release.version
        )
        self.description = ParraLabelContent(
            text: newInstalledAppVersion.release.description
        )
        if let type = newInstalledAppVersion.release.type.value {
            self.type = ParraLabelContent(text: type.userFacingString)
        } else {
            self.type = nil
        }
        self.createdAt = ParraLabelContent(
            text: newInstalledAppVersion.release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = newInstalledAppVersion.release.sections.elements.map {
            AppReleaseSectionContent($0)
        }
        self.header = ReleaseHeaderContent(
            newInstalledAppVersion.release.header
        )

        self.otherReleasesButton = if newInstalledAppVersion.configuration
            .hasOtherReleases
        {
            ParraTextButtonContent(
                text: ParraLabelContent(
                    text: "Previous Releases"
                ),
                isLoading: true
            )
        } else {
            nil
        }

        self.emptyStateContent = emptyStateContent
    }

    init(
        _ release: ParraAppRelease,
        emptyStateContent: ParraEmptyStateContent
    ) {
        self.id = release.id
        self.title = ParraLabelContent(text: release.name)
        self.subtitle = nil
        self.version = ParraLabelContent(text: release.version)
        self.description = ParraLabelContent(text: release.description)
        if let type = release.type.value {
            self.type = ParraLabelContent(text: type.userFacingString)
        } else {
            self.type = nil
        }
        self.createdAt = ParraLabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = release.sections.elements.map { AppReleaseSectionContent($0) }
        self.header = ReleaseHeaderContent(release.header)
        self.otherReleasesButton = nil
        self.emptyStateContent = emptyStateContent
    }

    init(
        _ release: AppReleaseStub,
        emptyStateContent: ParraEmptyStateContent
    ) {
        self.id = release.id
        self.title = ParraLabelContent(text: release.name)
        self.subtitle = nil
        self.version = ParraLabelContent(text: release.version)
        self.description = ParraLabelContent(text: release.description)

        if let type = release.type.value {
            self.type = ParraLabelContent(text: type.userFacingString)
        } else {
            self.type = nil
        }

        self.createdAt = ParraLabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = []
        self.header = ReleaseHeaderContent(release.header)
        self.otherReleasesButton = nil
        self.emptyStateContent = emptyStateContent
    }

    // MARK: - Internal

    let id: String
    let title: ParraLabelContent
    let subtitle: ParraLabelContent?
    let version: ParraLabelContent
    let type: ParraLabelContent?
    let createdAt: ParraLabelContent
    let description: ParraLabelContent?
    var sections: [AppReleaseSectionContent]
    let header: ReleaseHeaderContent?
    let otherReleasesButton: ParraTextButtonContent?
    let emptyStateContent: ParraEmptyStateContent
}
