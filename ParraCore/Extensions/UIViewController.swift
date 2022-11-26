//
//  UIViewController.swift
//  ParraCore
//
//  Created by Mick MacCallum on 11/26/22.
//  Copyright © 2022 Parra, Inc. All rights reserved.
//

import UIKit

public extension UIViewController {
    @available(iOS, deprecated: 13.0)
    static func topMostViewController() -> UIViewController? {
        // There does not appear to be a work-around for this yet for applications
        // that use multiple scenes.
        guard let window = UIApplication.shared.keyWindow else {
            return nil
        }

        return window.topViewController()
    }
}
