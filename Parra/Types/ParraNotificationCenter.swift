//
//  ParraNotificationCenter.swift
//  Parra
//
//  Created by Mick MacCallum on 6/24/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

public class ParraNotificationCenter: NotificationCenterType {
    public static let `default` = ParraNotificationCenter()
    private let underlyingNotificationCenter = NotificationCenter.default

    public func post(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable : Any]? = nil
    ) {
        Task {
            await postAsync(
                name: aName,
                object: anObject,
                userInfo: aUserInfo
            )
        }
    }

    public func postAsync(
        name aName: NSNotification.Name,
        object anObject: Any? = nil,
        userInfo aUserInfo: [AnyHashable : Any]? = nil
    ) async {
        parraLogTrace("Posting notification: \(aName.rawValue)")

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

    public func addObserver(
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

    public func addObserver(
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
}
