//
//  FAQs.swift
//  Parra
//
//  Created by Mick MacCallum on 12/3/24.
//

import Foundation

public struct ParraAppFaq: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String,
        body: String
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.body = body
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String
    public let body: String
}

public struct ParraAppFaqSection: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        title: String?,
        description: String?,
        items: [ParraAppFaq]
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.title = title
        self.description = description
        self.items = items
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let title: String?
    public let description: String?
    public let items: [ParraAppFaq]
}

public struct ParraAppFaqLayout: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        createdAt: String,
        updatedAt: String,
        deletedAt: String?,
        tenantId: String,
        title: String?,
        description: String?,
        appAreaId: String?,
        sections: [ParraAppFaqSection],
        feedbackForm: ParraFeedbackFormDataStub?
    ) {
        self.id = id
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
        self.tenantId = tenantId
        self.title = title
        self.description = description
        self.appAreaId = appAreaId
        self.sections = sections
        self.feedbackForm = feedbackForm
    }

    // MARK: - Public

    public let id: String
    public let createdAt: String
    public let updatedAt: String
    public let deletedAt: String?
    public let tenantId: String
    public let title: String?
    public let description: String?
    public let appAreaId: String?
    public let sections: [ParraAppFaqSection]
    public let feedbackForm: ParraFeedbackFormDataStub?
}
