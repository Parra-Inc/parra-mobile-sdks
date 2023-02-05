//
//  Parra.swift
//  Parra Core
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

/// The ParraCore module is primarily used for authenticating with the Parra API.  For usage beyond this, you'll need
/// to install and use other Parra libraries.
public class Parra: ParraModule {
    public static private(set) var name = "core"
        
    internal static var shared: Parra! = {
        let diskCacheURL = ParraDataManager.Path.networkCachesDirectory
        // Cache may reject image entries if they are greater than 10% of the cache's size
        // so these need to reflect that.
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 300 * 1024 * 1024,
            directory: diskCacheURL
        )

        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad

        let urlSession = URLSession(configuration: configuration)
        let dataManager = ParraDataManager()

        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: urlSession
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            networkManager: networkManager
        )

        let syncManager = ParraSyncManager(
            networkManager: networkManager,
            sessionManager: sessionManager
        )
        
        return Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager
        )
    }()
    
    public static internal(set) var config: ParraConfiguration = .default
    
    internal private(set) static var registeredModules: [String: ParraModule] = [:]
    
    internal let dataManager: ParraDataManager
    internal let syncManager: ParraSyncManager
    internal let sessionManager: ParraSessionManager
    internal let networkManager: ParraNetworkManager
        
    internal init(dataManager: ParraDataManager,
                  syncManager: ParraSyncManager,
                  sessionManager: ParraSessionManager,
                  networkManager: ParraNetworkManager) {
        
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.sessionManager = sessionManager
        self.networkManager = networkManager
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.

        addEventObservers()

        Task {
            await self.syncManager.startSyncTimer()
        }
    }
    
    deinit {
        // Being a good citizen. This should only happen when the singleton is destroyed when the
        // app is being killed anyway.
        removeEventObservers()
    }

    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling logout, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public static func logout(completion: (() -> Void)? = nil) {
        Task {
            await logout()

            completion?()
        }
    }

    /// Used to clear any cached credentials for the current user. After calling logout, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public static func logout() async {
        await shared.syncManager.enqueueSync(with: .immediate)
        await shared.dataManager.updateCredential(credential: nil)
    }

    // MARK: - Parra Modules
    
    /// Registers the provided ParraModule with the ParraCore module. This exists for usage by other Parra modules only. It is used
    /// to allow the Core module to identify which other Parra modules have been installed.
    public static func registerModule(module: ParraModule) {
        registeredModules[type(of: module).name] = module
    }
    
    /// Checks whether the provided module has already been registered with ParraCore
    public static func hasRegisteredModule(module: ParraModule.Type) -> Bool {
        return registeredModules[module.name] != nil
    }

    // MARK: - Synchronization

    /// Uploads any cached Parra data. This includes data like answers to questions.
    public static func triggerSync(completion: (() -> Void)? = nil) {
        Task {
            await triggerSync()
            
            completion?()
        }
    }
    
    /// Uploads any cached Parra data. This includes data like answers to questions.
    public static func triggerSync() async {
        await shared.triggerSync()
    }
    
    public func hasDataToSync() async -> Bool {
        return false // TODO:
    }
    
    /// Parra data is syncrhonized automatically. Use this method if you wish to trigger a synchronization event manually.
    /// This may be something you want to do in response to a significant event in your app, or in response to a low memory
    /// warning, for example. Note that in order to prevent excessive network activity it may take up to 30 seconds for the sync
    /// to complete after being initiated.
    public func triggerSync() async {
        // Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }
}
