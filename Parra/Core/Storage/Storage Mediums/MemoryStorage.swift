//
//  MemoryStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 3/1/22.
//

import Foundation

actor MemoryStorage: DataStorageMedium {
    private var underlyingStore = [String: Codable]()
    
    func read<T>(name: String) async throws -> T? where T : Decodable, T : Encodable {
        return underlyingStore[name] as? T
    }
    
    func write<T>(name: String, value: T?) async throws where T : Decodable, T : Encodable {
        if let value = value {
            underlyingStore[name] = value
        } else {
            underlyingStore.removeValue(forKey: name)
        }
    }
}
