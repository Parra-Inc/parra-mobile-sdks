//
//  FailableDecodable.swift
//  Parra
//
//  Created by Mick MacCallum on 10/15/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import Foundation

public struct NilFailureDecodable<Base>: Codable, Equatable,
    Hashable, Sendable where Base: Codable & Equatable & Hashable & Sendable
{
    // MARK: - Lifecycle

    public init(_ value: Base?) {
        self.value = value
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            self.value = nil
        } else {
            self.value = try? container.decode(Base.self)
        }
    }

    // MARK: - Public

    public let value: Base?
}

struct FailableDecodable<Base: Decodable>: Decodable {
    // MARK: - Lifecycle

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        do {
            self.result = try .success(container.decode(Base.self))
        } catch let decodeError as DecodingError {
            self.result = .failure(decodeError)
        } catch {
            throw error
        }
    }

    init(value: Base) {
        self.result = .success(value)
    }

    init(error: DecodingError) {
        self.result = .failure(error)
    }

    // MARK: - Internal

    let result: Result<Base, DecodingError>
}
