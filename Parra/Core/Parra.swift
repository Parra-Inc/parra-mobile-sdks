//
//  Parra.swift
//  Parra
//
//  Created by Michael MacCallum on 11/22/21.
//

import Foundation
import UIKit

/// The primary module used to interact with the Parra SDK.
/// Call ``Parra/Parra/initialize(options:authProvider:)-8d8fx`` in your `AppDelegate.didFinishLaunchingWithOptions`
/// method to configure the SDK.
public class Parra: ParraModule, ParraModuleStateAccessor {
    internal static private(set) var name = "Parra"

    internal let state: ParraState
    internal private(set) var configuration: ParraConfiguration

    internal lazy var feedback: ParraFeedback = {
        let parraFeedback = ParraFeedback(
            parra: self,
            dataManager: ParraFeedbackDataManager(
                parra: self,
                jsonEncoder: Parra.jsonCoding.jsonEncoder,
                jsonDecoder: Parra.jsonCoding.jsonDecoder,
                fileManager: Parra.fileManager
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

    internal private(set) static var fileManager: FileManager = {
        return .default
    }()

    internal static var _shared: Parra!


    @usableFromInline
    /// Unsafe to use before previously calling ``Parra/Parra/createInitialInstance``
    internal static func getExistingInstance() -> Parra {
        return _shared
    }

    internal static func createInitialInstance(
        with configuration: ParraConfiguration
    ) -> Parra {
        if let _shared {
            return _shared
        }

        _shared = createParraInstance(
            configuration: configuration,
            instanceConfiguration: .default
        )

        return _shared
    }

    /// Do NOT use this. This only exists to assist with automated tests. Absolutely never expose this publically.
    internal static func setSharedInstance(parra: Parra) {
        _shared = parra
    }

    internal let dataManager: ParraDataManager
    internal let syncManager: ParraSyncManager

    @usableFromInline
    internal let sessionManager: ParraSessionManager
    internal let networkManager: ParraNetworkManager
    internal let notificationCenter: NotificationCenterType

    internal init(
        state: ParraState,
        configuration: ParraConfiguration,
        dataManager: ParraDataManager,
        syncManager: ParraSyncManager,
        sessionManager: ParraSessionManager,
        networkManager: ParraNetworkManager,
        notificationCenter: NotificationCenterType
    ) {
        self.state = state
        self.configuration = configuration
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
        getExistingInstance().logout(completion: completion)
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
        await getExistingInstance().logout()
    }

    internal func logout() async {
        await syncManager.enqueueSync(with: .immediate)
        await dataManager.updateCredential(credential: nil)
        await syncManager.stopSyncTimer()
    }

    // MARK: - Synchronization

    /// Uploads any cached Parra data. This includes data like answers to questions.
    public static func triggerSync(completion: (() -> Void)? = nil) {
        getExistingInstance().triggerSync(completion: completion)
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
        await getExistingInstance().triggerSync()
    }

    internal func triggerSync() async {
        // Uploads any cached Parra data. This includes data like answers to questions.
        // Don't expose sync mode publically.
        await syncManager.enqueueSync(with: .eventual)
    }

    internal func hasDataToSync(since date: Date?) async -> Bool {
        return await sessionManager.hasDataToSync(since: date)
    }

    internal func synchronizeData() async throws {
        guard let response = try await sessionManager.synchronizeData() else {
            return
        }

        for module in await state.getAllRegisteredModules() {
            module.didReceiveSessionResponse(
                sessionResponse: response
            )
        }
    }

    // MARK: Configuration

    internal static func createParraInstance(
        configuration: ParraConfiguration,
        instanceConfiguration: ParraInstanceConfiguration
    ) -> Parra {
        let state = ParraState()
        let syncState = ParraSyncState()

        let credentialStorageModule = ParraStorageModule<ParraCredential>(
            dataStorageMedium: .fileSystem(
                baseUrl: instanceConfiguration.storageConfiguration.baseDirectory,
                folder: instanceConfiguration.storageConfiguration.storageDirectoryName,
                fileName: ParraDataManager.Key.userCredentialsKey,
                storeItemsSeparately: false,
                fileManager: fileManager
            ),
            jsonEncoder: instanceConfiguration.storageConfiguration.sessionJsonEncoder,
            jsonDecoder: instanceConfiguration.storageConfiguration.sessionJsonDecoder
        )

        let sessionStorageUrl = instanceConfiguration.storageConfiguration.baseDirectory
            .appendDirectory(instanceConfiguration.storageConfiguration.storageDirectoryName)
            .appendDirectory("sessions")

        let notificationCenter = ParraNotificationCenter()

        let credentialStorage = CredentialStorage(
            storageModule: credentialStorageModule
        )

        let sessionStorage = SessionStorage(
            sessionReader: SessionReader(
                basePath: sessionStorageUrl,
                sessionJsonDecoder: .parraDecoder,
                eventJsonDecoder: .spaceOptimizedDecoder,
                fileManager: fileManager
            ),
            sessionJsonEncoder: .parraEncoder,
            eventJsonEncoder: .spaceOptimizedEncoder
        )

        let dataManager = ParraDataManager(
            baseDirectory: instanceConfiguration.storageConfiguration.baseDirectory,
            credentialStorage: credentialStorage,
            sessionStorage: sessionStorage
        )

        let networkManager = ParraNetworkManager(
            state: state,
            dataManager: dataManager,
            urlSession: instanceConfiguration.networkConfiguration.urlSession,
            jsonEncoder: instanceConfiguration.networkConfiguration.jsonEncoder,
            jsonDecoder: instanceConfiguration.networkConfiguration.jsonDecoder
        )

        let sessionManager = ParraSessionManager(
            dataManager: dataManager,
            networkManager: networkManager,
            loggerOptions: configuration.loggerOptions
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
            configuration: configuration,
            dataManager: dataManager,
            syncManager: syncManager,
            sessionManager: sessionManager,
            networkManager: networkManager,
            notificationCenter: notificationCenter
        )
    }

    // MARK: - Theme

    public static func updateTheme(to newTheme: ParraTheme) {
        let parra = getExistingInstance()

        let oldTheme = parra.configuration.theme
        parra.configuration.theme = newTheme

        parra.notificationCenter.post(
            name: Parra.themeWillChangeNotification,
            object: nil,
            userInfo: [
                "oldTheme": oldTheme,
                "newTheme": newTheme,
            ]
        )
    }
}
