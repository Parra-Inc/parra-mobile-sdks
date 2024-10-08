//
//  UIViewController.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    public static func topMostViewController() -> UIViewController? {
        return safeGetKeyWindow()?.topViewController()
    }

    static func safeGetKeyWindow() -> UIWindow? {
        let app = UIApplication.shared

        return app
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }

    static func safeGetFirstNoTouchWindow() -> UIWindow? {
        return UIViewController.safeGetKeyWindow()?
            .windowScene?
            .windows
            .first {
                $0 is NoTouchEventWindow
            }
    }
}
