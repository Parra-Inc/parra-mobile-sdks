//
//  UserDefaultsStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

actor UserDefaultsStorage: PersistentStorageMedium, @unchecked Sendable {
    // MARK: - Lifecycle

    init(
        userDefaults: UserDefaults,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.userDefaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    // MARK: - Internal

    func read<T>(name: String) async throws -> T? where T: Codable {
        guard let data = userDefaults.data(forKey: name) else {
            return nil
        }

        return try jsonDecoder.decode(T.self, from: data)
    }

    func write(name: String, value: some Codable) async throws {
        let data = try jsonEncoder.encode(value)

        userDefaults.set(data, forKey: name)
    }

    func delete(name: String) async throws {
        userDefaults.removeObject(forKey: name)
    }

    // MARK: - Private

    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
}

// MARK: - UserDefaults + Sendable

extension UserDefaults: @unchecked Sendable {}
