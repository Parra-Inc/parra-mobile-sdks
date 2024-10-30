//
//  ParraPushManager.swift
//  Parra
//
//  Created by Mick MacCallum on 10/29/24.
//

import Foundation
import UserNotifications

private let logger = Logger()

public final class ParraPushManager {
    // MARK: - Lifecycle

    init(parraInternal: ParraInternal) {
        self.parraInternal = parraInternal
    }

    // MARK: - Public

    @MainActor
    public func getCurrentAuthorizationStatus() async -> UNAuthorizationStatus {
        return await getCurrentSettings().authorizationStatus
    }

    @MainActor
    public func getCurrentSettings() async -> UNNotificationSettings {
        return await center.notificationSettings()
    }

    public func requestPushPermission() {
        Task { @MainActor in
            do {
                let _ = try await requestPushPermission()
            } catch {
                logger.error("Failed to request push permission", error)
            }
        }
    }

    @MainActor
    @discardableResult
    public func requestPushPermission() async throws -> Bool {
        logger.info("Requesting push permission")
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .authorized:
            logger.info("Push permission is already authorized.")
            return true
        case .provisional:
            logger.info("Push permission is already authorized (provisionally).")
        case .denied:
            logger.info("Push permission is denied.")
            return false
        case .ephemeral:
            logger.info("Push permission is ephemeral.")
        case .notDetermined:
            logger.info("Push permission is not yet determined.")
        default:
            logger.info("Push permission has an unknown state.", [
                "state": String(settings.authorizationStatus.rawValue)
            ])
        }

        let pushOptions = Parra.default.parraInternal.configuration
            .pushNotificationOptions

        guard pushOptions.enabled else {
            throw ParraError.message(
                "Can not request push permission. Push notifications are not enabled in your Parra configuration."
            )
        }

        var authorizationOptions: UNAuthorizationOptions = []
        if pushOptions.alerts {
            authorizationOptions.insert(.alert)
        }
        if pushOptions.badges {
            authorizationOptions.insert(.badge)
        }
        if pushOptions.sounds {
            authorizationOptions.insert(.sound)
        }
        if pushOptions.provisional {
            authorizationOptions.insert(.provisional)
        }
        if pushOptions.openSettingsHandler != nil {
            authorizationOptions.insert(.providesAppNotificationSettings)
        }

        do {
            let result = try await center.requestAuthorization(
                options: authorizationOptions
            )

            if result {
                logger.info("Push notification permission granted.")
            } else {
                logger.info("Push notification permission not granted or undetermined.")
            }

            return result
        } catch {
            logger.error("Error requesting push permisssion.", error)

            throw error
        }
        //
        ////        let center = UNUserNotificationCenter.current()
        //
        //
        //        // Obtain the notification settings.
        //        let settings = await center.notificationSettings()
        //
        //
        //        // Verify the authorization status.
        //        guard (settings.authorizationStatus == .authorized) ||
        //                (settings.authorizationStatus == .provisional) else { return }
        //
        //
        //        if settings.alertSetting == .enabled {
        //            // Schedule an alert-only notification.
        //        } else {
        //            // Schedule a notification with a badge and sound.
        //        }
    }

    // MARK: - Internal

    let parraInternal: ParraInternal
    let center = UNUserNotificationCenter.current()
}
