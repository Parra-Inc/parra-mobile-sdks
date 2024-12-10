//
//  Reactions.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import Foundation

enum ReactionType: String, Codable {
    case emoji
    case custom
}

struct ReactionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        type: ReactionType,
        value: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.value = value
    }

    // MARK: - Internal

    let id: String
    let name: String
    let type: ReactionType
    let value: String
}

struct ReactionOptionGroup: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        description: String?,
        options: [ReactionOption]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.options = options
    }

    // MARK: - Internal

    let id: String
    let name: String
    let description: String?
    let options: [ReactionOption]
}

struct ReactionSummary: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        type: ReactionType,
        value: String,
        count: Int,
        reactionId: String?
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.value = value
        self.count = count
        self.reactionId = reactionId
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case type
        case value
        case count
        case reactionId
    }

    let id: String
    let name: String
    let type: ReactionType
    let value: String
    let count: Int
    let reactionId: String?
}
