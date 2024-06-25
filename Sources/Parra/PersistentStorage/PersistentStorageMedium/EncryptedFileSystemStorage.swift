//
//  EncryptedFileSystemStorage.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "File system storage medium")

// Do NOT allow overriding so dynamic dispatch can't be used to modify
// this class's behavior.
final class EncryptedFileSystemStorage: FileSystemStorage {
    // MARK: - Lifecycle

    override init(
        baseUrl: URL,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder,
        fileManager: FileManager
    ) {
        self.keychainStorage = KeychainStorage(
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder
        )

        super.init(
            baseUrl: baseUrl,
            jsonEncoder: jsonEncoder,
            jsonDecoder: jsonDecoder,
            fileManager: fileManager
        )

        logger
            .trace(
                "FileSystemStorage init with baseUrl: \(baseUrl.privateRelativePath())"
            )
        do {
            try fileManager.safeCreateDirectory(at: baseUrl)
        } catch {
            logger.error("Error creating directory", error, [
                "path": baseUrl.absoluteString
            ])
        }
    }

    // MARK: - Internal

    override func read<T>(name: String) throws -> T? where T: Codable {
        // Check if a password exists in keychain and a file exists on disk.
        // If both are present, use the password to decrypt the data, then
        // decode the resulting object.

        let passwordWrapper = try keychainStorage.read(
            name: name
        ) as KeychainStorage.PasswordWrapper?

        guard let password = passwordWrapper?.password else {
            return nil
        }

        let file = baseUrl.appendFilename(name)
        guard let encryptedData = try? Data(contentsOf: file) else {
            return nil
        }

        let decrypted = try CryptoUtils.decryptData(
            encryptedData,
            using: password
        )

        return try jsonDecoder.decode(T.self, from: decrypted)
    }

    override func write(name: String, value: some Codable) throws {
        let file = baseUrl.appendFilename(name)
        let decrypted = try jsonEncoder.encode(value)
        let (encrypted, keyString) = try CryptoUtils.encyptData(decrypted)

        try keychainStorage.write(
            name: name,
            value: KeychainStorage.PasswordWrapper(
                password: keyString
            )
        )

        try encrypted.write(to: file, options: .atomic)
    }

    override func delete(name: String) throws {
        try keychainStorage.delete(name: name)

        let url = baseUrl.appendFilename(name)

        if try fileManager.safeFileExists(at: url) {
            try fileManager.removeItem(at: url)
        }
    }

    // MARK: - Private

    private let keychainStorage: KeychainStorage
}
