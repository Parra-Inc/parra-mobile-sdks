//
//  PersistentStorageMedium.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

protocol PersistentStorageMedium {
    func read<T: Codable>(name: String) async throws -> T?
    func write<T: Codable>(name: String, value: T) async throws
    func delete(name: String) async throws
}
