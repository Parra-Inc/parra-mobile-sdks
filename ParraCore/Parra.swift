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
        let urlSession = URLSession(configuration: .default)
        let dataManager = ParraDataManager()
        
        let networkManager = ParraNetworkManager(
            dataManager: dataManager,
            urlSession: urlSession
        )
        
        let syncManager = ParraFeedbackSyncManager(
            networkManager: networkManager
        )
        
        return Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            networkManager: networkManager
        )
    }()
    
    internal private(set) var isInitialized = false
    
    internal private(set) static var registeredModules: [String: ParraModule] = [:]
    
    internal let dataManager: ParraDataManager
    internal let syncManager: ParraFeedbackSyncManager
    internal let networkManager: ParraNetworkManager
        
    internal init(dataManager: ParraDataManager,
                  syncManager: ParraFeedbackSyncManager,
                  networkManager: ParraNetworkManager) {
        
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.networkManager = networkManager
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.

        self.addEventObservers()
    }
    
    deinit {
        // Being a good citizen. This should only happen when the singleton is destroyed when the
        // app is being killed anyway.
        removeEventObservers()
    }
    
    /// Registers the provided ParraModule with the ParraCore module. This exists for usage by other Parra modules only. It is used
    /// to allow the Core module to identify which other Parra modules have been installed.
    public static func registerModule(module: ParraModule) {
        registeredModules[type(of: module).name] = module
    }
    
    /// Checks whether the provided module has already been registered with ParraCore
    public static func hasRegisteredModule(module: ParraModule.Type) -> Bool {
        return registeredModules[module.name] != nil
    }

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
    
    // MARK: - ParraModule Conformance
    
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
