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

private let logger = Logger(category: "Sync Event Extensions")

extension Parra {
    private static var backgroundTaskId: UIBackgroundTaskIdentifier?
    private static var hasStartedEventObservers = false

    private var notificationsToObserve: [(Notification.Name, Selector)] {
        [
            (
                UIApplication.didBecomeActiveNotification,
                #selector(applicationDidBecomeActive)
            ),
            (
                UIApplication.willResignActiveNotification,
                #selector(applicationWillResignActive)
            ),
            (
                UIApplication.didEnterBackgroundNotification,
                #selector(applicationDidEnterBackground)
            ),
            (
                UIApplication.significantTimeChangeNotification,
                #selector(significantTimeChange)
            ),
            (
                UIApplication.didReceiveMemoryWarningNotification,
                #selector(didReceiveMemoryWarning)
            ),
            (
                UIApplication.userDidTakeScreenshotNotification,
                #selector(didTakeScreenshot)
            ),
            (
                UIDevice.batteryLevelDidChangeNotification,
                #selector(batteryLevelChange)
            ),
            (
                UIDevice.batteryStateDidChangeNotification,
                #selector(batteryStateChange)
            ),
            (UIWindow.keyboardDidShowNotification, #selector(keyboardDidShow)),
            (UIWindow.keyboardDidHideNotification, #selector(keyboardDidHide)),
            (.NSProcessInfoPowerStateDidChange, #selector(powerStateDidChange)),
            (
                .NSBundleResourceRequestLowDiskSpace,
                #selector(didRequestLowDiskSpace)
            )
        ]
    }

    func addEventObservers() {
        guard NSClassFromString("XCTestCase") == nil,
              !Parra.hasStartedEventObservers else
        {
            return
        }

        Parra.hasStartedEventObservers = true

        // TODO: Before adding observer, should we read the current values of everything and
        // store them in user state?

        for (notificationName, selector) in notificationsToObserve {
            addObserver(for: notificationName, selector: selector)
        }

        UIDevice.current.isBatteryMonitoringEnabled = true
    }

    func removeEventObservers() {
        guard NSClassFromString("XCTestCase") == nil else {
            return
        }

        for (notificationName, _) in notificationsToObserve {
            removeObserver(for: notificationName)
        }

        UIDevice.current.isBatteryMonitoringEnabled = false
    }

    @MainActor
    @objc
    func applicationDidBecomeActive(notification: Notification) {
        if let taskId = Parra.backgroundTaskId,
           let app = notification.object as? UIApplication
        {
            app.endBackgroundTask(taskId)
        }

        logEvent(.appStateChanged, [
            "state": UIApplication.State.active.loggerDescription
        ])

        triggerEventualSyncFromNotification(notification: notification)
    }

    @MainActor
    @objc
    func applicationWillResignActive(notification: Notification) {
        logEvent(.appStateChanged, [
            "state": UIApplication.State.inactive.loggerDescription
        ])

        triggerSyncFromNotification(notification: notification)

        let endSession = { [self] in
            guard let taskId = Parra.backgroundTaskId else {
                return
            }

            Parra.backgroundTaskId = nil

            logger
                .debug("Background task: \(taskId) triggering session end")

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
            while Date().timeIntervalSince(startTime) < InternalConstants
                .backgroundTaskDuration
            {
                try await Task.sleep(for: 0.1)
            }

            logger
                .debug(
                    "Ending Parra background execution after \(InternalConstants.backgroundTaskDuration)s"
                )

            Task { @MainActor in
                await endSession()
            }
        }
    }

    @MainActor
    @objc
    func applicationDidEnterBackground(notification: Notification) {
        logEvent(.appStateChanged, [
            "state": UIApplication.State.background.loggerDescription
        ])
    }

    @MainActor
    @objc
    func significantTimeChange(notification: Notification) {
        logEvent(.significantTimeChange)

        triggerSync(with: .immediate)
    }

    @MainActor
    @objc
    func didReceiveMemoryWarning(notification: Notification) {
        logEvent(.memoryWarning)
    }

    @MainActor
    @objc
    func didTakeScreenshot(notification: Notification) {
        logEvent(.screenshotTaken)
    }

    @MainActor
    @objc
    func batteryLevelChange(notification: Notification) {
        logEvent(.batteryLevelChanged, [
            "battery_level": UIDevice.current.batteryLevel
        ])
    }

    @MainActor
    @objc
    func batteryStateChange(notification: Notification) {
        logEvent(.batteryStateChanged, [
            "battery_state": UIDevice.current.batteryState.loggerDescription
        ])
    }

    @MainActor
    @objc
    func keyboardDidShow(notification: Notification) {
        logEvent(.keyboardDidShow, keyboardFrameParams(from: notification))
    }

    @MainActor
    @objc
    func keyboardDidHide(notification: Notification) {
        logEvent(.keyboardDidHide, keyboardFrameParams(from: notification))
    }

    @MainActor
    @objc
    func powerStateDidChange(notification: Notification) {
        logEvent(.powerStateChanged, [
            "power_state": ProcessInfo.processInfo.powerState
                .loggerDescription
        ])
    }

    @MainActor
    @objc
    func didRequestLowDiskSpace(
        notification: Notification
    ) {
        let extra = URL.currentDiskUsage()?.sanitized.dictionary ?? [:]
        logEvent(.diskSpaceLow, extra)
    }

    @MainActor
    @objc
    private func triggerSyncFromNotification(
        notification: Notification
    ) {
        triggerSync(with: .immediate)
    }

    @MainActor
    @objc
    private func triggerEventualSyncFromNotification(
        notification: Notification
    ) {
        triggerSync(with: .eventual)
    }

    private func addObserver(
        for notificationName: Notification.Name,
        selector: Selector
    ) {
        notificationCenter.addObserver(
            self,
            selector: #selector(triggerEventualSyncFromNotification),
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

    private func keyboardFrameParams(from notification: Notification)
        -> [String: Any]
    {
        var params = [String: Any]()

        if let value = notification
            .userInfo?[UIWindow.keyboardFrameBeginUserInfoKey] as? NSValue
        {
            params["frame_begin"] = NSCoder.string(for: value.cgRectValue)
        }
        if let value = notification
            .userInfo?[UIWindow.keyboardFrameEndUserInfoKey] as? NSValue
        {
            params["frame_end"] = NSCoder.string(for: value.cgRectValue)
        }

        return params
    }

    private func triggerSync(with mode: ParraSyncMode) {
        Task {
            await syncManager.enqueueSync(with: mode)
        }
    }
}
