//
//  NoTouchEventWindow.swift
//  Parra
//
//  Created by Mick MacCallum on 3/25/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

class NoTouchEventWindow: UIWindow {
    override func hitTest(
        _ point: CGPoint,
        with event: UIEvent?
    ) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }

        return rootViewController?.view == hitView ? nil : hitView
    }
}
