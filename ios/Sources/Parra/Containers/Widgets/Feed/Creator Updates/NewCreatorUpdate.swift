//
//  NewCreatorUpdate.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import SwiftUI

struct NewCreatorUpdate: Hashable {
    // MARK: - Lifecycle

    init(template: CreatorUpdateTemplate) {
        self.selectedTemplate = template
        self.topic = template.topic.value
        self.title = template.title ?? ""
        self.body = template.body ?? ""
        self.attachments = []
        self.visibility = template.visibility
    }

    // MARK: - Internal

    var selectedTemplate: CreatorUpdateTemplate
    var topic: CreatorUpdateTopic?
    var title: String
    var body: String
    var attachments: [StatefulAttachment]
    var visibility: CreatorUpdateVisibility
}
