//
//  PersistentStorageMedium.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

protocol PersistentStorageMedium {
    func read<T: Codable>(name: String) throws -> T?
    func write<T: Codable>(name: String, value: T) throws
    func delete(name: String) throws
}
