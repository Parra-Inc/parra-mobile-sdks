//
//  Parra+SyncEvents.swift
//  Parra
//
//  Created by Michael MacCallum on 3/5/22.
//

import Foundation
import UIKit

// TODO: Everything here that is updated via notification should be checked and reported in the params
//       for significant events like app state change/session start/stop/etc.

fileprivate let logger = Logger(category: "Sync Event Extensions")

internal extension Parra {
    private static var backgroundTaskId: UIBackgroundTaskIdentifier?
    private static var hasStartedEventObservers = false

    private var notificationsToObserve: [(Notification.Name, Selector)] {
        [
            (UIApplication.didBecomeActiveNotification, #selector(self.applicationDidBecomeActive)),
            (UIApplication.willResignActiveNotification, #selector(self.applicationWillResignActive)),
            (UIApplication.didEnterBackgroundNotification, #selector(self.applicationDidEnterBackground)),
            (UIApplication.significantTimeChangeNotification, #selector(self.significantTimeChange)),
            (UIApplication.didReceiveMemoryWarningNotification, #selector(self.didReceiveMemoryWarning)),
            (UIApplication.userDidTakeScreenshotNotification, #selector(self.didTakeScreenshot)),
            (UIDevice.orientationDidChangeNotification, #selector(self.orientationDidChange)),
            (UIDevice.batteryLevelDidChangeNotification, #selector(self.batteryLevelChange)),
            (UIDevice.batteryStateDidChangeNotification, #selector(self.batteryStateChange)),
            (UIWindow.keyboardDidShowNotification, #selector(self.keyboardDidShow)),
            (UIWindow.keyboardDidHideNotification, #selector(self.keyboardDidHide)),
            // TODO: Need to access `ProcessInfo.thermalState` BEFORE registering this notification to receive updates.
            (ProcessInfo.thermalStateDidChangeNotification, #selector(self.thermalStateDidChange)),
            (.NSProcessInfoPowerStateDidChange, #selector(self.powerStateDidChange)),
            (.NSBundleResourceRequestLowDiskSpace, #selector(self.didRequestLowDiskSpace)),
        ]
    }

    func addEventObservers() {
        guard NSClassFromString("XCTestCase") == nil && !Parra.hasStartedEventObservers else {
            return
        }

        Parra.hasStartedEventObservers = true

        // TODO: Before adding observer, should we read the current values of everything and
        // store them in user state?

        for (notificationName, selector) in notificationsToObserve {
            addObserver(for: notificationName, selector: selector)
        }

        // TODO: Not receiving these. Maybe just a simulator issue?
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    func removeEventObservers() {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        for (notificationName, _) in notificationsToObserve {
            removeObserver(for: notificationName)
        }

        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        UIDevice.current.isBatteryMonitoringEnabled = false
    }

    @MainActor
    @objc func applicationDidBecomeActive(notification: Notification) {
        withInitializationCheck { [self] in
            if let taskId = Parra.backgroundTaskId,
               let app = notification.object as? UIApplication {

                app.endBackgroundTask(taskId)
            }

            logEvent(.appStateChanged, [
                "state": UIApplication.State.active.loggerDescription
            ])

            triggerEventualSyncFromNotification(notification: notification)
        }
    }

    @MainActor
    @objc func applicationWillResignActive(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.appStateChanged, [
                "state": UIApplication.State.inactive.loggerDescription
            ])

            triggerSyncFromNotification(notification: notification)

            let endSession = { [self] in
                guard let taskId = Parra.backgroundTaskId else {
                    return
                }

                Parra.backgroundTaskId = nil

                logger.debug("Background task: \(taskId) triggering session end")

                await sessionManager.endSession()

                UIApplication.shared.endBackgroundTask(taskId)
            }

            Parra.backgroundTaskId = UIApplication.shared.beginBackgroundTask(
                withName: InternalConstants.backgroundTaskName
            ) {
                logger.debug("Background task expiration handler invoked")

                Task { @MainActor in
                    await endSession()
                }
            }

            let startTime = Date()
            Task(priority: .background) {
                while Date().timeIntervalSince(startTime) < InternalConstants.backgroundTaskDuration {
                    try await Task.sleep(for: 0.1)
                }

                logger.debug("Ending Parra background execution after \(InternalConstants.backgroundTaskDuration)s")

                Task { @MainActor in
                    await endSession()
                }
            }
        }
    }

    @MainActor
    @objc func applicationDidEnterBackground(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.appStateChanged, [
                "state": UIApplication.State.background.loggerDescription
            ])
        }
    }

    @MainActor
    @objc func significantTimeChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.significantTimeChange)

            await syncManager.enqueueSync(with: .immediate)
        }
    }

    @MainActor
    @objc func didReceiveMemoryWarning(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.memoryWarning)
        }
    }

    @MainActor
    @objc func didTakeScreenshot(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.screenshotTaken)
        }
    }

    @MainActor
    @objc func orientationDidChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.orientationChanged, [
                "orientation": UIDevice.current.orientation.loggerDescription
            ])
        }
    }

    @MainActor
    @objc func batteryLevelChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.batteryLevelChanged, [
                "battery_level": UIDevice.current.batteryLevel
            ])
        }
    }

    @MainActor
    @objc func batteryStateChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.batteryStateChanged, [
                "battery_state": UIDevice.current.batteryState.loggerDescription
            ])
        }
    }

    @MainActor
    @objc func keyboardDidShow(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.keyboardDidShow, keyboardFrameParams(from: notification))
        }
    }

    @MainActor
    @objc func keyboardDidHide(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.keyboardDidHide, keyboardFrameParams(from: notification))
        }
    }

    @MainActor
    @objc func thermalStateDidChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.thermalStateChanged, [
                "thermal_state": ProcessInfo.processInfo.thermalState.loggerDescription
            ])
        }
    }

    @MainActor
    @objc func powerStateDidChange(notification: Notification) {
        withInitializationCheck { [self] in
            logEvent(.powerStateChanged, [
                "power_state": ProcessInfo.processInfo.powerState.loggerDescription
            ])
        }
    }

    @MainActor
    @objc func didRequestLowDiskSpace(
        notification: Notification
    ) {
        withInitializationCheck { [self] in
            let extra = URL.currentDiskUsage()?.sanitized.dictionary ?? [:]
            logEvent(.diskSpaceLow, extra)
        }
    }

    @MainActor
    @objc private func triggerSyncFromNotification(
        notification: Notification
    ) {
        withInitializationCheck { [self] in
            await syncManager.enqueueSync(with: .immediate)
        }
    }
    
    @MainActor
    @objc private func triggerEventualSyncFromNotification(
        notification: Notification
    ) {
        withInitializationCheck { [self] in
            await syncManager.enqueueSync(with: .eventual)
        }
    }

    /// Prevent processing events if initialization hasn't occurred.
    private func withInitializationCheck(
        _ function: @escaping () async -> Void
    ) {
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

    private func keyboardFrameParams(from notification: Notification) -> [String : Any] {
        var params = [String : Any]()

        if let value = notification.userInfo?[UIWindow.keyboardFrameBeginUserInfoKey] as? NSValue {
            params["frame_begin"] = NSCoder.string(for: value.cgRectValue)
        }
        if let value = notification.userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as? NSValue {
            params["frame_end"] = NSCoder.string(for: value.cgRectValue)
        }

        return params
    }
}
