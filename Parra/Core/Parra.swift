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
public class Parra: ParraModule, ParraModuleStateAccessor {
    internal static private(set) var name = "parra"

    internal let state: ParraState
    internal let configState: ParraConfigState

    internal lazy var feedback: ParraFeedback = {
        let parraFeedback = ParraFeedback(
            parra: self,
            dataManager: ParraFeedbackDataManager(
                parra: self,
                jsonEncoder: Parra.jsonCoding.jsonEncoder,
                jsonDecoder: Parra.jsonCoding.jsonDecoder
            )
        )

        Task {
            await state.registerModule(module: parraFeedback)
        }

        return parraFeedback
    }()

    internal private(set) static var jsonCoding: (
        jsonEncoder: JSONEncoder,
        jsonDecoder: JSONDecoder
    ) = {
        return (
            jsonEncoder: JSONEncoder.parraEncoder,
            jsonDecoder: JSONDecoder.parraDecoder
        )
    }()

    internal static var shared: Parra! = {
        let state = ParraState()
        let configState = ParraConfigState()
        let syncState = ParraSyncState()

        let defaultJsonEncoder = Parra.jsonCoding.jsonEncoder
        let defaultJsonDecoder = Parra.jsonCoding.jsonDecoder

        let diskCacheURL = ParraDataManager.Path.networkCachesDirectory
        // Cache may reject image entries if they are greater than 10% of the cache's size
        // so these need to reflect that.
        let cache = URLCache(
            memoryCapacity: 50 * 1024 * 1024,
            diskCapacity: 300 * 1024 * 1024,
            directory: diskCacheURL
        )

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.urlCache = cache
        sessionConfig.requestCachePolicy = .returnCacheDataElseLoad

        let notificationCenter = ParraNotificationCenter()
        let urlSession = URLSession(configuration: sessionConfig)
        let dataManager = ParraDataManager(
            jsonEncoder: .spaceOptimizedEncoder,
            jsonDecoder: defaultJsonDecoder
        )

        let networkManager = ParraNetworkManager(
            state: state,
            configState: configState,
            dataManager: dataManager,
            urlSession: urlSession,
            jsonEncoder: defaultJsonEncoder,
            jsonDecoder: defaultJsonDecoder
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            networkManager: networkManager,
            loggerOptions: ParraConfigState.defaultState.loggerOptions
        )

        let syncManager = ParraSyncManager(
            state: state,
            syncState: syncState,
            networkManager: networkManager,
            sessionManager: sessionManager,
            notificationCenter: notificationCenter
        )

        Logger.loggerBackend = sessionManager

        return Parra(
            state: state,
            configState: configState,
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
        state: ParraState,
        configState: ParraConfigState,
        dataManager: ParraDataManager,
        syncManager: ParraSyncManager,
        sessionManager: ParraSessionManager,
        networkManager: ParraNetworkManager,
        notificationCenter: NotificationCenterType
    ) {
        self.state = state
        self.configState = configState
        self.dataManager = dataManager
        self.syncManager = syncManager
        self.sessionManager = sessionManager
        self.networkManager = networkManager
        self.notificationCenter = notificationCenter
        
        UIFont.registerFontsIfNeeded() // Needs to be called before any UI is displayed.
    }
    
    deinit {
        // This should only happen when the singleton is destroyed when the
        // app is being killed, or during unit tests.
        removeEventObservers()
    }

    // MARK: - Authentication

    /// Used to clear any cached credentials for the current user. After calling logout, the authentication provider you configured
    /// will be invoked the very next time the Parra API is accessed.
    public static func logout(completion: (() -> Void)? = nil) {
        shared.logout(completion: completion)
    }

    internal func logout(completion: (() -> Void)? = nil) {
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
        await shared.logout()
    }

    internal func logout() async {
        await syncManager.enqueueSync(with: .immediate)
        await dataManager.updateCredential(credential: nil)
        await syncManager.stopSyncTimer()
    }

    // MARK: - Synchronization

    /// Uploads any cached Parra data. This includes data like answers to questions.
    public static func triggerSync(completion: (() -> Void)? = nil) {
        shared.triggerSync(completion: completion)
    }

    internal func triggerSync(completion: (() -> Void)? = nil) {
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

    internal func triggerSync() async {
        // Uploads any cached Parra data. This includes data like answers to questions.
        // Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }

    internal func hasDataToSync() async -> Bool {
        return await sessionManager.hasDataToSync()
    }

    internal func synchronizeData() async throws {
        guard let response = try await sessionManager.synchronizeData() else {
            return
        }

        for module in (await state.getAllRegisteredModules()).values {
            module.didReceiveSessionResponse(sessionResponse: response)
        }
    }
}
