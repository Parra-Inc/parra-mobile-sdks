//
//  ParraNotificationCenter.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Parra notification center")

class ParraNotificationCenter: NotificationCenterType, @unchecked Sendable {
    // MARK: - Lifecycle

    init(notificationCenter: NotificationCenter) {
        self.underlyingNotificationCenter = notificationCenter
    }

    // MARK: - Internal

    // Default instance should use the default notification center instance
    // because we need to assume that this is what developers will use
    // externally to receive some notifications.
    static let `default` = ParraNotificationCenter(notificationCenter: .default)

    let underlyingNotificationCenter: NotificationCenter

    @MainActor
    func post(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable: Any]? = nil
    ) {
        logger.trace("Posting notification: \(aName.rawValue)")

        underlyingNotificationCenter.post(
            name: aName,
            object: anObject,
            userInfo: aUserInfo
        )
    }

    func postAsync(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable: Any]? = nil
    ) async {
        await MainActor.run {
            post(
                name: aName,
                object: anObject,
                userInfo: aUserInfo
            )
        }
    }

    func addObserver(
        _ observer: Any,
        selector aSelector: Selector,
        name aName: NSNotification.Name?,
        object anObject: Any?
    ) {
        underlyingNotificationCenter.addObserver(
            observer,
            selector: aSelector,
            name: aName,
            object: anObject
        )
    }

    func addObserver(
        forName name: NSNotification.Name?,
        object obj: Any? = nil,
        queue: OperationQueue? = nil,
        using block: @escaping @Sendable (Notification) -> Void
    ) -> NSObjectProtocol {
        underlyingNotificationCenter.addObserver(
            forName: name,
            object: obj,
            queue: queue,
            using: block
        )
    }

    func removeObserver(
        _ observer: Any,
        name aName: NSNotification.Name?,
        object anObject: Any?
    ) {
        underlyingNotificationCenter.removeObserver(
            observer,
            name: aName,
            object: anObject
        )
    }

    func removeObserver(_ observer: Any) {
        underlyingNotificationCenter.removeObserver(observer)
    }
}
