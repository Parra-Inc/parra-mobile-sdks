//
//  UIViewController.swift
//  Parra
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

extension UIViewController {
    @MainActor
    static func topMostViewController() -> UIViewController? {
        return safeGetKeyWindow()?.topViewController()
    }

    @MainActor
    static func safeGetKeyWindow() -> UIWindow? {
        let app = UIApplication.shared

        return app
            .connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}
