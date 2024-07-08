//
//  ParraUserDefaultsStorageModule.swift
//  Parra
//
//  Created by Mick MacCallum on 7/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

class ParraUserDefaultsStorageModule<DataType: Codable> {
    // MARK: - Lifecycle

    init(
        key: String,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.key = "parra_\(key)"
        self.storage = UserDefaultsStorage(
            userDefaults: .parra,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )
    }

    // MARK: - Internal

    func read() -> DataType? {
        do {
            if let loadedData: DataType = try storage.read(
                name: key
            ) {
                return loadedData
            }

            return nil
        } catch {
            Logger.error(
                "Error reading data from user defaults",
                error,
                [
                    "key": key
                ]
            )

            return nil
        }
    }

    func write(
        value: DataType?
    ) throws {
        guard let value else {
            try storage.delete(name: key)

            return
        }

        try storage.write(
            name: key,
            value: value
        )
    }

    // MARK: - Private

    private let key: String
    private let storage: UserDefaultsStorage
}
