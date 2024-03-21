//
//  AppReleaseContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init(
        _ release: AppRelease,
        isStandalone: Bool
    ) {
        if isStandalone {
            self.title = LabelContent(text: "What's new")
            self.subtitle = LabelContent(text: release.name)
        } else {
            self.title = LabelContent(text: release.name)
            self.subtitle = nil
        }

        self.id = release.id
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
    }

    init(
        _ release: AppReleaseStub,
        isStandalone: Bool
    ) {
        if isStandalone {
            self.title = LabelContent(text: "What's new")
            self.subtitle = LabelContent(text: release.name)
        } else {
            self.title = LabelContent(text: release.name)
            self.subtitle = nil
        }

        self.id = release.id
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
}
