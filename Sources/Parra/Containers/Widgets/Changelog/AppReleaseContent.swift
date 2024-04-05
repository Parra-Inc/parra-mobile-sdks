//
//  AppReleaseContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseContent: ContainerContent, Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ newInstalledAppVersion: NewInstalledVersionInfo
    ) {
        self.id = newInstalledAppVersion.release.id
        self.title = LabelContent(
            text: newInstalledAppVersion.configuration.title
        )
        self.subtitle = LabelContent(
            text: newInstalledAppVersion.release.name
        )
        self.version = LabelContent(
            text: newInstalledAppVersion.release.version
        )
        self.description = LabelContent(
            text: newInstalledAppVersion.release.description
        )
        self.type = LabelContent(
            text: newInstalledAppVersion.release.type.userFacingString
        )
        self.createdAt = LabelContent(
            text: newInstalledAppVersion.release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = newInstalledAppVersion.release.sections.map {
            AppReleaseSectionContent($0)
        }
        self.header = ReleaseHeaderContent(
            newInstalledAppVersion.release.header
        )

        self.otherReleasesButton = if newInstalledAppVersion.configuration
            .hasOtherReleases
        {
            TextButtonContent(
                text: LabelContent(
                    text: "Previous Releases"
                )
            )
        } else {
            nil
        }
    }

    init(
        _ release: AppRelease
    ) {
        self.id = release.id
        self.title = LabelContent(text: release.name)
        self.subtitle = nil
        self.version = LabelContent(text: release.version)
        self.description = LabelContent(text: release.description)
        self.type = LabelContent(text: release.type.userFacingString)
        self.createdAt = LabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = release.sections.map { AppReleaseSectionContent($0) }
        self.header = ReleaseHeaderContent(release.header)
        self.otherReleasesButton = nil
    }

    init(
        _ release: AppReleaseStub
    ) {
        self.id = release.id
        self.title = LabelContent(text: release.name)
        self.subtitle = nil
        self.version = LabelContent(text: release.version)
        self.description = LabelContent(text: release.description)
        self.type = LabelContent(text: release.type.userFacingString)
        self.createdAt = LabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = AppReleaseSection.validStates()
            .map { AppReleaseSectionContent($0) }
        self.header = ReleaseHeaderContent(release.header)
        self.otherReleasesButton = nil
    }

    // MARK: - Internal

    let id: String
    let title: LabelContent
    let subtitle: LabelContent?
    let version: LabelContent
    let type: LabelContent
    let createdAt: LabelContent
    let description: LabelContent?
    let sections: [AppReleaseSectionContent]
    let header: ReleaseHeaderContent?
    let otherReleasesButton: TextButtonContent?
}
