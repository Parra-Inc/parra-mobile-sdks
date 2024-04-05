//
//  ParraCredential.swift
//  Parra
//
//  Created by Michael MacCallum on 11/28/21.
//

import Foundation
import UIKit

public struct ParraCredential: Codable, Equatable {
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
            self.token = try container.decode(String.self, forKey: .accessToken)
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
