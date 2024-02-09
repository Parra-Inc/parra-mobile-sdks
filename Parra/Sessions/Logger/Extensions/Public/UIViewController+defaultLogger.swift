//
//  UIViewController+defaultLogger.swift
//  Parra
//
//  Created by Mick MacCallum on 9/1/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import ObjectiveC
import UIKit

final class ObjectAssociation<T: AnyObject> {
    // MARK: - Lifecycle

    /// - Parameter policy: An association policy that will be used when linking objects.
    public init(
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    ) {
        self.policy = policy
    }

    // MARK: - Public

    /// Accesses associated object.
    /// - Parameter index: An object whose associated object is to be accessed.
    public subscript(index: AnyObject) -> T? {
        get {
            return objc_getAssociatedObject(
                index,
                Unmanaged.passUnretained(self).toOpaque()
            ) as! T?
        }

        set {
            objc_setAssociatedObject(
                index,
                Unmanaged.passUnretained(self).toOpaque(),
                newValue,
                policy
            )
        }
    }

    // MARK: - Private

    private let policy: objc_AssociationPolicy
}

public extension UIViewController {
    private static let association = ObjectAssociation<Logger>()

    var logger: Logger {
        if let existing = UIViewController.association[self] {
            return existing
        }

        // TODO: Audit/make into helper for other classes.
        let category = String(describing: type(of: self))

        let fileId = type(of: self).description().split(separator: ".")
            .joined(separator: "/")

        var extra: [String: Any] = [
            "hasNavigationController": navigationController != nil
        ]
        if let title {
            extra["title"] = title
        }

        let new = Logger(
            category: "ViewController (\(category))",
            extra: extra,
            fileId: fileId,
            function: ""
        )

        UIViewController.association[self] = new

        return new
    }
}
