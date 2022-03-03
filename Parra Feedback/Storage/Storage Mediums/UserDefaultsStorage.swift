//
//  UserDefaultsStorage.swift
//  Parra Feedback
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

actor UserDefaultsStorage: DataStorageMedium {
    private let userDefaults: UserDefaults
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    
    init(userDefaults: UserDefaults, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.userDefaults = userDefaults
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }
    
    func read<T>(name: String) async throws -> T? where T : Decodable, T : Encodable {
        guard let data = userDefaults.data(forKey: name) else {
            return nil
        }
        
        return try jsonDecoder.decode(T.self, from: data)
    }
    
    func write<T>(name: String, value: T?) async throws where T : Decodable, T : Encodable {
        if let value = value {
            let data = try jsonEncoder.encode(value)
            
            userDefaults.set(data, forKey: name)
        } else {
            userDefaults.removeObject(forKey: name)
        }
    }
}
