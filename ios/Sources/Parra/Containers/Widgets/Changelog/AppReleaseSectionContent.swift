//
//  AppReleaseSectionContent.swift
//  Parra
//
//  Created by Mick MacCallum on 3/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct AppReleaseSectionContent: Identifiable, Hashable {
    // MARK: - Lifecycle

    init(_ section: ParraAppReleaseSection) {
        self.id = section.id
        self.title = ParraLabelContent(text: section.title)
        self.items = section.items.map { TicketStubContent($0.ticket) }
    }

    init(
        id: String,
        title: ParraLabelContent,
        items: [TicketStubContent]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }

    // MARK: - Internal

    /// Used in contexts where Ticket is rendered with placeholder
    /// redaction. Needs to be computed to have unique IDs for display in lists.
    static var redacted: AppReleaseSectionContent {
        AppReleaseSectionContent(
            id: UUID().uuidString,
            title: ParraLabelContent(text: "Sample title!"),
            items: [
                .redacted, .redacted, .redacted, .redacted, .redacted
            ]
        )
    }

    let id: String
    let title: ParraLabelContent
    let items: [TicketStubContent]
}
