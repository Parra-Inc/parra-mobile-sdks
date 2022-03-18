//
//  ParraStorageModule.swift
//  ParraCore
//
//  Created by Mick MacCallum on 3/13/22.
//

import Foundation

public actor ParraStorageModule<DataType: Codable> {
    // Whether or not data has previously been loaded from disk.
    internal private(set) var isLoaded = false
    internal let dataStorageMedium: DataStorageMedium
    internal let persistentStorage: (medium: PersistentStorageMedium, key: String)?
    private var storageCache: [String: DataType] = [:]
    
    public init(dataStorageMedium: DataStorageMedium) {
        self.dataStorageMedium = dataStorageMedium
        
        switch dataStorageMedium {
        case .memory:
            self.persistentStorage = nil
        case .fileSystem(folder: let folder, fileName: let fileName):
            let baseUrl = ParraDataManager.Path.parraDirectory.appendingPathComponent(folder, isDirectory: true)
            
            let fileSystemStorage = FileSystemStorage(
                baseUrl: baseUrl,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            )
            
            self.persistentStorage = (fileSystemStorage, fileName)
        case .userDefaults(key: let key):
            let userDefaultsStorage = UserDefaultsStorage(
                userDefaults: .standard,
                jsonEncoder: .parraEncoder,
                jsonDecoder: .parraDecoder
            )
            
            self.persistentStorage = (userDefaultsStorage, key)
        }
    }
    
    internal func loadData() async {
        defer {
            isLoaded = true
        }

        guard let persistentStorage = persistentStorage else {
            return
        }
        
        guard let existingData: [String: DataType] = try? await persistentStorage.medium.read(
            name: persistentStorage.key
        ) else {
            return
        }
        
        storageCache = existingData
    }
    
    public func currentData() async -> [String: DataType] {
        if !isLoaded {
            await loadData()
        }

        return storageCache
    }
    
    public func read(name: String) async -> DataType? {
        if !isLoaded {
            await loadData()
        }
        
        return storageCache[name]
    }
    
    public func write(name: String, value: DataType?) async throws {
        if !isLoaded {
            await loadData()
        }

        storageCache[name] = value
        
        if let persistentStorage = persistentStorage {
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
        
        if let persistentStorage = persistentStorage {
            try? await persistentStorage.medium.write(
                name: persistentStorage.key,
                value: storageCache
            )
        }
    }

    public func clear() async {
        storageCache.removeAll()
        
        if let persistentStorage = persistentStorage {
            try? await persistentStorage.medium.delete(
                name: persistentStorage.key
            )
        }
    }
}
