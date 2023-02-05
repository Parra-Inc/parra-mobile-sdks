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

    func addEventObservers() {
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
        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.appState(state: .active))

        triggerEventualSyncFromNotification(notification: notification)
    }

    @MainActor
    @objc func applicationWillResignActive(notification: Notification) {
        Parra.logAnalyticsEvent(ParraSessionEventType._Internal.appState(state: .inactive))

        guard let application = notification.object as? UIApplication else {
            return
        }

        Parra.backgroundTaskId = application.beginBackgroundTask(
            withName: Constant.backgroundTaskName
        ) { [weak application] in
            parraLogV("Background task expiration handler invoked")
            guard let app = application, let taskId = Parra.backgroundTaskId else {
                return
            }

            parraLogV("Background task: \(taskId) triggering session end")

            Task {
                await Parra.shared.sessionManager.endSession()

                app.endBackgroundTask(taskId)
            }
        }

        triggerSyncFromNotification(notification: notification)
    }

    @MainActor
    @objc func applicationDidEnterBackground(notification: Notification) {
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
