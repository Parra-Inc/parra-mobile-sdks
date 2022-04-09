//
//  Parra.swift
//  Parra Core
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

public typealias ParraFeedbackAuthenticationProvider = () async throws -> ParraCredential

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
    
    public let dataManager: ParraDataManager
    internal let syncManager: ParraFeedbackSyncManager
    internal let networkManager: ParraNetworkManager
        
    internal init(dataManager: ParraDataManager,
                  syncManager: ParraFeedbackSyncManager,
                  networkManager: ParraNetworkManager) {
        
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.networkManager = networkManager
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.

        addEventObservers()
    }
    
    deinit {
        // Being a good citizen. This should only happen when the singleton is destroyed when the
        // app is being killed anyway.
        removeEventObservers()
    }
    
    public static func registerModule(module: ParraModule) {
        registeredModules[type(of: module).name] = module
    }
    
    public static func hasRegisteredModule(module: ParraModule.Type) -> Bool {
        return registeredModules[module.name] != nil
    }
    
    // TODO: Do we really even need this???
    @objc public static func logout(completion: (() -> Void)? = nil) {
        Task {
            await logout()
            
            completion?()
        }
    }

    @nonobjc public static func logout() async {
        await shared.dataManager.updateCredential(credential: nil)
    }

    /// Uploads any cached Parra data. This includes data like answers to questions.
    @objc public static func triggerSync(completion: (() -> Void)? = nil) {
        Task {
            await triggerSync()
            
            completion?()
        }
    }
    
    /// Uploads any cached Parra data. This includes data like answers to questions.
    @nonobjc public static func triggerSync() async {
        await shared.triggerSync()
    }
    
    // MARK: - ParraModule Conformance
    
    public func hasDataToSync() async -> Bool {
        return false // TODO:
    }
    
    public func triggerSync() async {
        // Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }
}
