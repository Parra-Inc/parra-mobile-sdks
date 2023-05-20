//
//  Parra+SyncEvents.swift
//  Parra Core
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

internal extension Parra {
    private static var backgroundTaskId: UIBackgroundTaskIdentifier?
    private static var hasStartedEventObservers = false

    func addEventObservers() {
        if Parra.hasStartedEventObservers {
            return
        }

        Parra.hasStartedEventObservers = true

        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self,
                                       selector: #selector(self.applicationDidBecomeActive),
                                       name: UIApplication.didBecomeActiveNotification,
                                       object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.applicationWillResignActive),
                                       name: UIApplication.willResignActiveNotification,
                                       object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.applicationDidEnterBackground),
                                       name: UIApplication.didEnterBackgroundNotification,
                                       object: nil)

        notificationCenter.addObserver(self, selector: #selector(self.triggerEventualSyncFromNotification),
                                       name: UIApplication.significantTimeChangeNotification,
                                       object: nil)
    }
    
    func removeEventObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.significantTimeChangeNotification,
                                                  object: nil)
    }

    @MainActor
    @objc func applicationDidBecomeActive(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        if let taskId = Parra.backgroundTaskId,
            let app = notification.object as? UIApplication {

            app.endBackgroundTask(taskId)
        }

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.appState(state: .active))

        triggerEventualSyncFromNotification(notification: notification)
    }

    @MainActor
    @objc func applicationWillResignActive(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.appState(state: .inactive))

        triggerSyncFromNotification(notification: notification)

        let endSession = {
            guard let taskId = Parra.backgroundTaskId else {
                return
            }

            Parra.backgroundTaskId = nil

            parraLogDebug("Background task: \(taskId) triggering session end")

            await Parra.shared.sessionManager.endSession()

            UIApplication.shared.endBackgroundTask(taskId)
        }

        Parra.backgroundTaskId = UIApplication.shared.beginBackgroundTask(
            withName: Constant.backgroundTaskName
        ) {
            parraLogDebug("Background task expiration handler invoked")

            Task { @MainActor in
                await endSession()
            }
        }

        let startTime = Date()
        Task(priority: .background) {
            while Date().timeIntervalSince(startTime) < Constant.backgroundTaskDuration {
                try await Task.sleep(nanoseconds: 100_000_000)
            }

            parraLogDebug("Ending Parra background execution after \(Constant.backgroundTaskDuration)s")

            Task { @MainActor in
                await endSession()
            }
        }
    }

    @MainActor
    @objc func applicationDidEnterBackground(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.appState(state: .background))
    }

    @MainActor
    @objc private func triggerSyncFromNotification(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        Task {
            await syncManager.enqueueSync(with: .immediate)
        }
    }
    
    @MainActor
    @objc private func triggerEventualSyncFromNotification(notification: Notification) {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }
        
        Task {
            await syncManager.enqueueSync(with: .eventual)
        }
    }
}
