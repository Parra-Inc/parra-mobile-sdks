//
//  ParraStorageModule.swift
//  Parra
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public actor ParraStorageModule<DataType: Codable> {
    // Whether or not data has previously been loaded from disk.
    internal private(set) var isLoaded = false
    internal let dataStorageMedium: DataStorageMedium
    internal let persistentStorage: (medium: PersistentStorageMedium, key: String)?
    internal private(set) var storageCache: [String : DataType] = [:]
    
    internal var description: String {
        return """
        ParraStorageModule{
            dataType: \(DataType.self),
            dataStorageMedium: \(dataStorageMedium),
            persistentStorageMedium: \(String(describing: persistentStorage?.medium)),
            persistentStorageKey: \(String(describing: persistentStorage?.medium)),
            isLoaded: \(isLoaded),
            storageCache: \(storageCache),
        }
        """
    }

    private var storeItemsSeparately: Bool {
        switch dataStorageMedium {
        case .memory, .userDefaults(_):
            return false
        case .fileSystem(_, _, let storeItemsSeparately):
            return storeItemsSeparately
        }
    }

    public init(
        dataStorageMedium: DataStorageMedium,
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) {
        self.dataStorageMedium = dataStorageMedium

        switch dataStorageMedium {
        case .memory:
            self.persistentStorage = nil
        case .fileSystem(folder: let folder, fileName: let fileName, _):
            let baseUrl = ParraDataManager.Path.parraDirectory
                .safeAppendDirectory(folder)

            let fileSystemStorage = FileSystemStorage(
                baseUrl: baseUrl,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            )
            
            self.persistentStorage = (fileSystemStorage, fileName)
        case .userDefaults(key: let key):
            let userDefaults = UserDefaults(suiteName: Parra.bundle().bundleIdentifier) ?? .standard
            
            let userDefaultsStorage = UserDefaultsStorage(
                userDefaults: userDefaults,
                jsonEncoder: jsonEncoder,
                jsonDecoder: jsonDecoder
            )
            
            self.persistentStorage = (userDefaultsStorage, key)
        }
    }
    
    internal func loadData() async {
        defer {
            isLoaded = true
        }
        
        // Persistent storage is missing when the underlying store is a memory store.
        guard let persistentStorage else {
            return
        }

        if let fileSystem = persistentStorage.medium as? FileSystemStorage, storeItemsSeparately {
            storageCache = await fileSystem.readAllInDirectory()
        } else {
            do {
                if let existingData: [String : DataType] = try await persistentStorage.medium.read(
                    name: persistentStorage.key
                ) {
                    storageCache = existingData
                }
            } catch let error {
                Logger.error("Error loading data from persistent storage", error, [
                    "key": persistentStorage.key
                ])
            }
        }
    }
    
    public func currentData() async -> [String : DataType] {
        if !isLoaded {
            await loadData()
        }
        
        return storageCache
    }
    
    public func read(name: String) async -> DataType? {
        if !isLoaded {
            await loadData()
        }
        
        if let cached = storageCache[name] {
            return cached
        }

        if let persistentStorage, storeItemsSeparately {

            do {
                if let loadedData: [String : DataType] = try await persistentStorage.medium.read(name: name) {
                    storageCache.merge(loadedData) { (_, new) in new }

                    return storageCache[name]
                }
            } catch let error {
                Logger.error("Error reading data from persistent storage", error, [
                    "key": persistentStorage.key
                ])
            }
        }

        return nil
    }
    
    public func write(
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
            try await persistentStorage.medium.write(
                name: name,
                value: value
            )
        } else {
            try await persistentStorage.medium.write(
                name: persistentStorage.key,
                value: storageCache
            )
        }
    }
    
    public func delete(name: String) async {
        if !isLoaded {
            await loadData()
        }
        
        storageCache.removeValue(forKey: name)

        guard let persistentStorage else {
            return
        }

        do {
            if storeItemsSeparately {
                try await persistentStorage.medium.delete(
                    name: name
                )
            } else {
                try await persistentStorage.medium.write(
                    name: persistentStorage.key,
                    value: storageCache
                )
            }
        } catch let error {
            Logger.error("ParraStorageModule error deleting file", error)
        }
    }
    
    public func clear() async {
        defer {
            storageCache.removeAll()
        }

        guard let persistentStorage else {
            return
        }

        do {
            if storeItemsSeparately {
                for (name, _) in storageCache {
                    try await persistentStorage.medium.delete(
                        name: name
                    )
                }
            } else {
                try await persistentStorage.medium.delete(
                    name: persistentStorage.key
                )
            }
        } catch let error {
            Logger.error("Error deleting data from persistent storage", error, [
                "key": persistentStorage.key
            ])
        }
    }
}
