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

    init(_ release: AppRelease) {
        self.id = release.id
        self.name = LabelContent(text: release.name)
        self.version = LabelContent(text: release.version)
        self.whatsNewTitle = LabelContent(text: "What's new")
        self.description = LabelContent(text: release.description)
        self.type = LabelContent(text: release.type.userFacingString)
        self.createdAt = LabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )
        self.sections = release.sections.map { AppReleaseSectionContent($0) }
    }

    init(_ release: AppReleaseStub) {
        self.id = release.id
        self.name = LabelContent(text: release.name)
        self.version = LabelContent(text: release.version)
        self.whatsNewTitle = LabelContent(text: "What's new")
        self.description = LabelContent(text: release.description)
        self.type = LabelContent(text: release.type.userFacingString)
        self.createdAt = LabelContent(
            text: release.createdAt.timeAgo(
                dateTimeStyle: .numeric
            )
        )

        self.sections = AppReleaseSection.validStates()
            .map { AppReleaseSectionContent($0) }
    }

    // MARK: - Internal

    let id: String
    let name: LabelContent
    let version: LabelContent
    let type: LabelContent
    let createdAt: LabelContent
    let description: LabelContent?
    let sections: [AppReleaseSectionContent]

    let whatsNewTitle: LabelContent
}
