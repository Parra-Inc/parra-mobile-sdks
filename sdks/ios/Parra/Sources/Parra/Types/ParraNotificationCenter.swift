//
//  ParraNotificationCenter.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

private let logger = Logger(category: "Parra notification center")

class ParraNotificationCenter: NotificationCenterType {
    // MARK: - Lifecycle

    init() {}

    // MARK: - Internal

    static let `default` = ParraNotificationCenter()

    let underlyingNotificationCenter = NotificationCenter()

    func post(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable: Any]? = nil
    ) {
        Task {
            await postAsync(
                name: aName,
                object: anObject,
                userInfo: aUserInfo
            )
        }
    }

    func postAsync(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable: Any]? = nil
    ) async {
        logger.trace("Posting notification: \(aName.rawValue)")

        await MainActor.run {
            DispatchQueue.main.async {
                self.underlyingNotificationCenter.post(
                    name: aName,
                    object: anObject,
                    userInfo: aUserInfo
                )
            }
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
        object obj: Any?,
        queue: OperationQueue?,
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
