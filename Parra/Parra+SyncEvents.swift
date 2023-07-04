//
//  Parra+SyncEvents.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

internal extension Parra {
    private static var backgroundTaskId: UIBackgroundTaskIdentifier?
    private static var hasStartedEventObservers = false

    private var notificationsToObserve: [(Notification.Name, Selector)] {
        [
            (UIApplication.didBecomeActiveNotification, #selector(self.applicationDidBecomeActive)),
            (UIApplication.willResignActiveNotification, #selector(self.applicationWillResignActive)),
            (UIApplication.didEnterBackgroundNotification, #selector(self.applicationDidEnterBackground)),
            (UIApplication.significantTimeChangeNotification, #selector(self.triggerEventualSyncFromNotification)),
        ]
    }

    func addEventObservers() {
        guard NSClassFromString("XCTestCase") == nil && !Parra.hasStartedEventObservers else {
            return
        }

        Parra.hasStartedEventObservers = true

        for (notificationName, selector) in notificationsToObserve {
            addObserver(for: notificationName, selector: selector)
        }
    }

    func removeEventObservers() {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        for (notificationName, _) in notificationsToObserve {
            removeObserver(for: notificationName)
        }
    }

    @MainActor
    @objc func applicationDidBecomeActive(notification: Notification) {
        withInitializationCheck { [self] in
            if let taskId = Parra.backgroundTaskId,
               let app = notification.object as? UIApplication {

                app.endBackgroundTask(taskId)
            }

            logEvent(.appStateChanged(state: .active))

            triggerEventualSyncFromNotification(notification: notification)
        }
    }

    @MainActor
    @objc func applicationWillResignActive(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.appStateChanged(state: .inactive))

            triggerSyncFromNotification(notification: notification)

            let endSession = { [self] in
                guard let taskId = Parra.backgroundTaskId else {
                    return
                }

                Parra.backgroundTaskId = nil

                parraLogDebug("Background task: \(taskId) triggering session end")

                await sessionManager.endSession()

                UIApplication.shared.endBackgroundTask(taskId)
            }

            Parra.backgroundTaskId = UIApplication.shared.beginBackgroundTask(
                withName: InternalConstants.backgroundTaskName
            ) {
                parraLogDebug("Background task expiration handler invoked")

                Task { @MainActor in
                    await endSession()
                }
            }

            let startTime = Date()
            Task(priority: .background) {
                while Date().timeIntervalSince(startTime) < InternalConstants.backgroundTaskDuration {
                    try await Task.sleep(for: 0.1)
                }

                parraLogDebug("Ending Parra background execution after \(InternalConstants.backgroundTaskDuration)s")

                Task { @MainActor in
                    await endSession()
                }
            }
        }
    }

    @MainActor
    @objc func applicationDidEnterBackground(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.appStateChanged(state: .background))
        }
    }

    @MainActor
    @objc private func triggerSyncFromNotification(notification: Notification) {
        withInitializationCheck { [self] in
            await syncManager.enqueueSync(with: .immediate)
        }
    }
    
    @MainActor
    @objc private func triggerEventualSyncFromNotification(notification: Notification) {
        withInitializationCheck { [self] in
            await syncManager.enqueueSync(with: .eventual)
        }
    }

    /// Prevent processing events if initialization hasn't occurred.
    private func withInitializationCheck(_ function: @escaping () async -> Void) {
        Task {
            guard await state.isInitialized() else {
                return
            }

            Task { @MainActor in
                await function()
            }
        }
    }

    private func addObserver(
        for notificationName: Notification.Name,
        selector: Selector
    ) {
        notificationCenter.addObserver(
            self,
            selector: #selector(self.triggerEventualSyncFromNotification),
            name: UIApplication.significantTimeChangeNotification,
            object: nil
        )
    }

    private func removeObserver(
        for notificationName: Notification.Name
    ) {
        notificationCenter.removeObserver(
            self,
            name: notificationName,
            object: nil
        )
    }
}
