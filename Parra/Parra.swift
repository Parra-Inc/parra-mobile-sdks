//
//  Parra.swift
//  Parra
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

/// The Parra module is primarily used for authenticating with the Parra API.  For usage beyond this, you'll need
/// to install and use other Parra libraries.
public class Parra: ParraModule {
    internal static private(set) var name = "core"

    @MainActor
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

        let notificationCenter = ParraNotificationCenter.default
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
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        return Parra(
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager,
            notificationCenter: notificationCenter
        )
    }()

    internal let dataManager: ParraDataManager
    internal let syncManager: ParraSyncManager
    internal let sessionManager: ParraSessionManager
    internal let networkManager: ParraNetworkManager
    internal let notificationCenter: NotificationCenterType
        
    internal init(
        dataManager: ParraDataManager,
        syncManager: ParraSyncManager,
        sessionManager: ParraSessionManager,
        networkManager: ParraNetworkManager,
        notificationCenter: NotificationCenterType
    ) {
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.sessionManager = sessionManager
        self.networkManager = networkManager
        self.notificationCenter = notificationCenter
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.
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

            DispatchQueue.main.async {
                completion?()
            }
        }
    }

    /// Used to clear any cached credentials for the current user. After calling logout, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public static func logout() async {
        await shared.syncManager.enqueueSync(with: .immediate)
        await shared.dataManager.updateCredential(credential: nil)
        await shared.syncManager.stopSyncTimer()
    }

    // MARK: - Synchronization

    /// Uploads any cached Parra data. This includes data like answers to questions.
    public static func triggerSync(completion: (() -> Void)? = nil) {
        Task {
            await triggerSync()
            
            completion?()
        }
    }
    
    /// Parra data is syncrhonized automatically. Use this method if you wish to trigger a synchronization event manually.
    /// This may be something you want to do in response to a significant event in your app, or in response to a low memory
    /// warning, for example. Note that in order to prevent excessive network activity it may take up to 30 seconds for the sync
    /// to complete after being initiated.
    public static func triggerSync() async {
        await shared.triggerSync()
    }

    /// Uploads any cached Parra data. This includes data like answers to questions.
    internal func triggerSync() async {
        // Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }

    internal func hasDataToSync() async -> Bool {
        return await sessionManager.hasDataToSync()
    }

    internal func synchronizeData() async {
        guard let response = await sessionManager.synchronizeData() else {
            return
        }

        for module in (await ParraGlobalState.shared.getAllRegisteredModules()).values {
            module.didReceiveSessionResponse(sessionResponse: response)
        }
    }
}
