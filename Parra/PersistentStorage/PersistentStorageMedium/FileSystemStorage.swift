//
//  FileStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

fileprivate let logger = Logger(category: "File system storage medium")

internal actor FileSystemStorage: PersistentStorageMedium {
    private let fileManager = FileManager.default
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let baseUrl: URL
    
    internal init(
        baseUrl: URL,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.baseUrl = baseUrl

        logger.trace("FileSystemStorage init with baseUrl: \(baseUrl.safeNonEncodedPath())")

        // TODO: Think about this more later, but I think this is a fatalError()
        do {
            try fileManager.safeCreateDirectory(at: baseUrl)
        } catch let error {
            logger.error("Error creating directory", error, [
                "path": baseUrl.absoluteString
            ])
        }
    }
    
    internal func read<T>(name: String) async throws -> T? where T: Codable {
        let file = baseUrl.safeAppendPathComponent(name)
        if let data = try? Data(contentsOf: file) {
            return try jsonDecoder.decode(T.self, from: data)
        }

        return nil
    }

    internal func readAllInDirectory<T>() async -> [String : T] where T: Codable {
        guard let enumerator = fileManager.enumerator(
            atPath: baseUrl.safeNonEncodedPath()
        ) else {
            return [:]
        }

        let result = enumerator.reduce([String : T]()) { [weak fileManager] partialResult, element in
            var accumulator = partialResult

            guard let fileManager, let fileName = element as? String else {
                return accumulator
            }

            logger.trace("readAllInDirectory reading file: \(fileName)")

            let path = baseUrl.safeAppendPathComponent(fileName)
            var isDirectory: ObjCBool = false
            let exists = fileManager.fileExists(
                atPath: path.safeNonEncodedPath(),
                isDirectory: &isDirectory
            )

            if !exists || isDirectory.boolValue || fileName.starts(with: ".") {
                logger.trace("readAllInDirectory skipping file: \(fileName) - is likely hidden or a directory")
                return accumulator
            }

            logger.trace("readAllInDirectory file: \(fileName) exists and is not hidden or a directory")

            do {
                let data = try Data(contentsOf: path)
                let next = try jsonDecoder.decode(T.self, from: data)

                accumulator[fileName] = next

                logger.trace("readAllInDirectory reading file: \(fileName) into cache")
            } catch let error {
                logger.error("readAllInDirectory", error)
            }

            return accumulator
        }

        logger.debug("readAllInDirectory read \(result.count) item(s) into cache")

        return result
    }
    
    internal func write<T>(name: String, value: T) async throws where T: Codable {
        let file = baseUrl.safeAppendPathComponent(name)
        let data = try jsonEncoder.encode(value)
        
        try data.write(to: file, options: .atomic)
    }
    
    internal func delete(name: String) async throws {
        let url = baseUrl.safeAppendPathComponent(name)

        if try fileManager.safeFileExists(at: url) {
            try fileManager.removeItem(at: url)
        }
    }
}
