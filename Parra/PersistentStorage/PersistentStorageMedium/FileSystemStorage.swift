//
//  FileSystemStorage.swift
//  Parra
//
//  Created by Michael MacCallum on 2/28/22.
//

import Foundation

private let logger = Logger(category: "File system storage medium")

actor FileSystemStorage: PersistentStorageMedium {
    // MARK: - Lifecycle

    init(
        baseUrl: URL,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) {
        self.baseUrl = baseUrl
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
        self.fileManager = fileManager

        logger
            .trace(
                "FileSystemStorage init with baseUrl: \(baseUrl.privateRelativePath())"
            )

        // TODO: Think about this more later, but I think this is a fatalError()
        do {
            try fileManager.safeCreateDirectory(at: baseUrl)
        } catch {
            logger.error("Error creating directory", error, [
                "path": baseUrl.absoluteString
            ])
        }
    }

    // MARK: - Internal

    func read<T>(name: String) async throws -> T? where T: Codable {
        let file = baseUrl.appendFilename(name)
        if let data = try? Data(contentsOf: file) {
            return try jsonDecoder.decode(T.self, from: data)
        }

        return nil
    }

    func readAllInDirectory<T>() async -> [String: T] where T: Codable {
        guard let enumerator = fileManager.enumerator(
            atPath: baseUrl.nonEncodedPath()
        ) else {
            return [:]
        }

        let result = enumerator
            .reduce([String: T](
            )) { [weak fileManager] partialResult, element in
                var accumulator = partialResult

                guard let fileManager, let fileName = element as? String else {
                    return accumulator
                }

                logger.trace("readAllInDirectory reading file: \(fileName)")

                let path = baseUrl.appendFilename(fileName)
                var isDirectory: ObjCBool = false
                let exists = fileManager.fileExists(
                    atPath: path.nonEncodedPath(),
                    isDirectory: &isDirectory
                )

                if !exists || isDirectory.boolValue || fileName
                    .starts(with: ".")
                {
                    logger
                        .trace(
                            "readAllInDirectory skipping file: \(fileName) - is likely hidden or a directory"
                        )
                    return accumulator
                }

                logger
                    .trace(
                        "readAllInDirectory file: \(fileName) exists and is not hidden or a directory"
                    )

                do {
                    let data = try Data(contentsOf: path)
                    let next = try jsonDecoder.decode(T.self, from: data)

                    accumulator[fileName] = next

                    logger
                        .trace(
                            "readAllInDirectory reading file: \(fileName) into cache"
                        )
                } catch {
                    logger.error("readAllInDirectory", error)
                }

                return accumulator
            }

        logger
            .debug("readAllInDirectory read \(result.count) item(s) into cache")

        return result
    }

    func write(name: String, value: some Codable) async throws {
        let file = baseUrl.appendFilename(name)
        let data = try jsonEncoder.encode(value)

        try data.write(to: file, options: .atomic)
    }

    func delete(name: String) async throws {
        let url = baseUrl.appendFilename(name)

        if try fileManager.safeFileExists(at: url) {
            try fileManager.removeItem(at: url)
        }
    }

    // MARK: - Private

    private let baseUrl: URL
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder
    private let fileManager: FileManager
}
