//
//  ParraStorageModule.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

actor ParraStorageModule<DataType: Codable> {
    // MARK: - Lifecycle

    init(
        dataStorageMedium: DataStorageMedium,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.dataStorageMedium = dataStorageMedium

        switch dataStorageMedium {
        case .memory:
            self.persistentStorage = nil
        case .fileSystem(
            let baseUrl,
            let folder,
            let fileName,
            _,
            let fileManager
        ):
            let storage = FileSystemStorage(
                baseUrl: baseUrl.appendDirectory(folder),
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder,
                fileManager: fileManager
            )

            self.persistentStorage = (storage, fileName)
        case .fileSystemEncrypted(
            let baseUrl,
            let folder,
            let fileName,
            let fileManager
        ):
            let storage = EncryptedFileSystemStorage(
                baseUrl: baseUrl.appendDirectory(folder),
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder,
                fileManager: fileManager
            )

            self.persistentStorage = (storage, fileName)
        case .keychain(let key):
            let storage = KeychainStorage(
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            )

            self.persistentStorage = (storage, key)
        }
    }

    // MARK: - Internal

    // Whether or not data has previously been loaded from disk.
    private(set) var isLoaded = false
    let dataStorageMedium: DataStorageMedium
    let persistentStorage: (medium: PersistentStorageMedium, key: String)?
    private(set) var storageCache: [String: DataType] = [:]

    var description: String {
        return """
            ParraStorageModule{
                dataType: \(DataType.self),
                dataStorageMedium: \(dataStorageMedium),
                persistentStorageMedium: \(String(
            describing: persistentStorage?
            .medium
            )),
                persistentStorageKey: \(String(
            describing: persistentStorage?
            .medium
            )),
                isLoaded: \(isLoaded),
                storageCache: \(storageCache),
            }
            """
        }

    func loadData() async {
        defer {
            isLoaded = true
        }

        // Persistent storage is missing when the underlying store is a memory store.
        guard let persistentStorage else {
            return
        }

        if let fileSystem = persistentStorage.medium as? FileSystemStorage,
           storeItemsSeparately
        {
            storageCache = fileSystem.readAllInDirectory()
        } else {
            do {
                if let existingData: [String: DataType] =
                    try persistentStorage.medium.read(
                        name: persistentStorage.key
                    )
                {
                    storageCache = existingData
                }
            } catch {
                Logger.error(
                    "Error loading data from persistent storage",
                    error,
                    [
                        "key": persistentStorage.key
                    ]
                )
            }
        }
    }

    func currentData() async -> [String: DataType] {
        if !isLoaded {
            await loadData()
        }

        return storageCache
    }

    func read(
        name: String,
        deleteOnError: Bool = false
    ) async -> DataType? {
        if !isLoaded {
            await loadData()
        }

        if let cached = storageCache[name] {
            return cached
        }

        if let persistentStorage {
            do {
                if storeItemsSeparately {
                    if let loadedData: DataType =
                        try persistentStorage.medium.read(name: name)
                    {
                        storageCache[name] = loadedData

                        return storageCache[name]
                    }
                } else {
                    if let loadedData: [String: DataType] =
                        try persistentStorage.medium.read(name: name)
                    {
                        storageCache.merge(loadedData) { _, new in new }

                        return storageCache[name]
                    }
                }
            } catch {
                Logger.error(
                    "Error reading data from persistent storage",
                    error,
                    [
                        "key": persistentStorage.key,
                        "willDelete": "\(deleteOnError)"
                    ]
                )

                if deleteOnError {
                    await delete(name: name)
                }
            }
        }

        return nil
    }

    func write(
        name: String,
        value: DataType?
    ) async throws {
        if !isLoaded {
            await loadData()
        }

        storageCache[name] = value

        guard let value else {
            await delete(name: name)

            return
        }

        guard let persistentStorage else {
            return
        }

        if storeItemsSeparately {
            try persistentStorage.medium.write(
                name: name,
                value: value
            )
        } else {
            try persistentStorage.medium.write(
                name: persistentStorage.key,
                value: storageCache
            )
        }
    }

    func delete(name: String) async {
        if !isLoaded {
            await loadData()
        }

        storageCache.removeValue(forKey: name)

        guard let persistentStorage else {
            return
        }

        do {
            if storeItemsSeparately {
                try persistentStorage.medium.delete(
                    name: name
                )
            } else {
                try persistentStorage.medium.write(
                    name: persistentStorage.key,
                    value: storageCache
                )
            }
        } catch {
            Logger.debug("ParraStorageModule couldn't delete file", [
                "name": name,
                "reason": error.localizedDescription
            ])
        }
    }

    func clear() async {
        defer {
            storageCache.removeAll()
        }

        guard let persistentStorage else {
            return
        }

        do {
            if storeItemsSeparately {
                for (name, _) in storageCache {
                    try persistentStorage.medium.delete(
                        name: name
                    )
                }
            } else {
                try persistentStorage.medium.delete(
                    name: persistentStorage.key
                )
            }
        } catch {
            Logger.error("Error deleting data from persistent storage", error, [
                "key": persistentStorage.key
            ])
        }
    }

    // MARK: - Private

    private var storeItemsSeparately: Bool {
        switch dataStorageMedium {
        case .memory, .keychain:
            return false
        case .fileSystemEncrypted:
            return true
        case .fileSystem(_, _, _, let storeItemsSeparately, _):
            return storeItemsSeparately
        }
    }
}
