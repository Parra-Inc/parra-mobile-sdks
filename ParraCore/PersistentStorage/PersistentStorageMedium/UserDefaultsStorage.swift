//
//  UserDefaultsStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

internal actor UserDefaultsStorage: PersistentStorageMedium, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    internal init(userDefaults: UserDefaults,
                  jsonEncoder: JSONEncoder,
                  jsonDecoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    internal func read<T>(name: String) async throws -> T? where T: Codable {
        guard let data = userDefaults.data(forKey: name) else {
            return nil
        }
        
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    internal func write<T>(name: String, value: T) async throws where T: Codable {
        let data = try jsonEncoder.encode(value)
        
        userDefaults.set(data, forKey: name)
    }
    
    internal func delete(name: String) async throws {
        userDefaults.removeObject(forKey: name)
    }
}
