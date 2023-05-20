//
//  UIViewController.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

public extension UIViewController {
    static func topMostViewController() -> UIViewController? {
        return safeGetKeyWindow()?.topViewController()
    }

    static func safeGetKeyWindow() -> UIWindow? {
        let app = UIApplication.shared

        if #available(iOS 15.0, *) {
            return app
                .connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first
        }

        return app.windows.first
    }
}
