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
        userId: String,
        user: ParraUserNameStub?
    ) {
        self.id = id
        self.optionId = optionId
        self.userId = userId
        self.user = user
    }

    // MARK: - Internal

    enum CodingKeys: String, CodingKey {
        case id
        case optionId
        case userId
        case user
    }

    let id: String
    let optionId: String
    let userId: String
    let user: ParraUserNameStub?
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

struct ParraUserNameStub: Codable, Equatable, Hashable, Identifiable {
    // MARK: - Lifecycle

    init(id: String, name: String) {
        self.id = id
        self.name = name
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(String.self, forKey: .id)

        if let name = try container.decodeIfPresent(
            String.self,
            forKey: .name
        ) {
            self.name = name
        } else {
            if let first = id.split(separator: "-").first,
               let num = Int(first, radix: 16)
            {
                self.name = "User \(num)"
            } else {
                self.name = "Unknown User"
            }
        }
    }

    // MARK: - Internal

    let id: String
    let name: String
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
        originalReactionId: String?,
        users: [ParraUserNameStub]?
    ) {
        self.id = id
        self.firstReactionAt = firstReactionAt
        self.name = name
        self.type = type
        self.value = value
        self.count = count
        self.reactionId = reactionId
        self.originalReactionId = originalReactionId
        self.users = .init(users)
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

    let users: PartiallyDecodableArray<ParraUserNameStub>?

    /// Used when toggling reaction state, this keeps track of what the reaction
    /// id was while the state is toggled and a temporary reactionId is applied.
    let originalReactionId: String?
}
