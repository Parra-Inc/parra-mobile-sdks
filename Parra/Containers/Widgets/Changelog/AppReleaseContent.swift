//
//  AppReleaseContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

// MARK: - CGSize + Hashable

extension CGSize: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(width)
        hasher.combine(height)
    }
}

struct ReleaseHeaderContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init?(_ releaseHeader: ReleaseHeader?) {
        guard let releaseHeader else {
            return nil
        }

        self.id = releaseHeader.id
        self.size = CGSize(
            width: releaseHeader.size.width,
            height: releaseHeader.size.height
        )
        self.url = releaseHeader.url
    }

    // MARK: - Public

    public let id: String
    public let size: CGSize
    public let url: String
}

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
        self.header = ReleaseHeaderContent(release.header)
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
        self.header = nil
    }

    // MARK: - Internal

    let id: String
    let name: LabelContent
    let version: LabelContent
    let type: LabelContent
    let createdAt: LabelContent
    let description: LabelContent?
    let sections: [AppReleaseSectionContent]
    let header: ReleaseHeaderContent?

    let whatsNewTitle: LabelContent
}
