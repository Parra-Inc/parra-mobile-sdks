//
//  ParraUser.swift
//  Parra
//
//  Created by Mick MacCallum on 4/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraUser: Equatable, Codable {
    // MARK: - Public

    public struct Info: Equatable, Codable {
        // TODO: this
    }

    public struct Credential: Codable, Equatable {
        // MARK: - Lifecycle

        public init(token: String) {
            self.token = token
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(
                keyedBy: CodingKeys.self
            )

            if let token = try? container.decode(String.self, forKey: .token) {
                self.token = token
            } else {
                self.token = try container.decode(
                    String.self,
                    forKey: .accessToken
                )
            }
        }

        // MARK: - Public

        public let token: String

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(token, forKey: .token)
        }

        // MARK: - Internal

        enum CodingKeys: String, CodingKey {
            case token
            case accessToken
        }
    }

    // MARK: - Internal

    let credential: Credential
    let info: Info
}
