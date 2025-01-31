//
//  Reactions.swift
//  Parra
//
//  Created by Mick MacCallum on 12/9/24.
//

import Foundation

struct CreateReactionRequestBody: Codable, Equatable, Hashable {
    // MARK: - Lifecycle

    init(
        optionId: String
    ) {
        self.optionId = optionId
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case optionId
    }

    let optionId: String
}

struct Reaction: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        optionId: String,
        userId: String
    ) {
        self.id = id
        self.optionId = optionId
        self.userId = userId
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case optionId
        case userId
    }

    let id: String
    let optionId: String
    let userId: String
}

public enum ParraReactionType: String, Codable {
    case emoji
    case custom
}

public struct ParraReactionOption: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        type: ParraReactionType,
        value: String
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.value = value
    }

    // MARK: - Public

    public let id: String
    public let name: String
    public let type: ParraReactionType
    public let value: String
}

public struct ParraReactionOptionGroup: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        name: String,
        description: String?,
        options: [ParraReactionOption]
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.options = options
    }

    // MARK: - Public

    public let id: String
    public let name: String
    public let description: String?
    public let options: [ParraReactionOption]
}

public struct ParraReactionSummary: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(
        id: String,
        firstReactionAt: Date,
        name: String,
        type: ParraReactionType,
        value: String,
        count: Int,
        reactionId: String?,
        originalReactionId: String?
    ) {
        self.id = id
        self.firstReactionAt = firstReactionAt
        self.name = name
        self.type = type
        self.value = value
        self.count = count
        self.reactionId = reactionId
        self.originalReactionId = originalReactionId
    }

    // MARK: - Public

    public let id: String
    public let firstReactionAt: Date
    public let name: String
    public let type: ParraReactionType
    public let value: String
    public let count: Int
    public let reactionId: String?

    // MARK: - Internal

    /// Used when toggling reaction state, this keeps track of what the reaction
    /// id was while the state is toggled and a temporary reactionId is applied.
    let originalReactionId: String?
}
