//
//  FileStorage.swift
//  Parra Core
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

internal actor FileSystemStorage: PersistentStorageMedium {
    private let fileManager = FileManager.default
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let baseUrl: URL
    
    internal init(baseUrl: URL, jsonEncoder: JSONEncoder, jsonDecoder: JSONDecoder) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.baseUrl = baseUrl
        
        // TODO: Think about this more later, but I think this is a fatalError()
        try? fileManager.safeCreateDirectory(at: baseUrl)
    }
    
    internal func read<T>(name: String) async throws -> T? where T: Codable {
        let file = baseUrl.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: file) else {
            return nil
        }
        
        return try jsonDecoder.decode(T.self, from: data)
    }

    internal func readAllInDirectory<T>() async -> [String: T] where T: Codable {
        guard let enumerator = fileManager.enumerator(
            atPath: baseUrl.safeNonEncodedPath()
        ) else {
            return [:]
        }

        let result = enumerator.reduce([String: T]()) { [weak fileManager] partialResult, element in
            var accumulator = partialResult

            guard let fileManager, let fileName = element as? String else {
                return accumulator
            }

            let path = baseUrl.safeAppendPathComponent(fileName)
            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(atPath: path.safeNonEncodedPath(), isDirectory: &isDirectory)

            if !exists || isDirectory.boolValue || fileName.starts(with: ".") {
                return accumulator
            }

            do {
                let data = try Data(contentsOf: path)
                let next = try jsonDecoder.decode(T.self, from: data)

                accumulator[fileName] = next
            } catch let error {
                parraLogV("readAllInDirectory error: \(error.localizedDescription)")
            }

            return accumulator
        }

        return result
    }
    
    internal func write<T>(name: String, value: T) async throws where T: Codable {
        let file = baseUrl.appendingPathComponent(name)
        let data = try jsonEncoder.encode(value)
        
        try data.write(to: file, options: .atomic)
    }
    
    internal func delete(name: String) async throws {
        let file = baseUrl.appendingPathComponent(name)
        
        try fileManager.removeItem(at: file)
    }
}
