//
//  SafeAreaInsetsKey.swift
//  Parra
//
//  Created by Mick MacCallum on 2/15/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        guard let window = UIViewController.safeGetKeyWindow() else {
            return .zero
        }

        return EdgeInsets(window.safeAreaInsets)
    }
}

extension EnvironmentValues {
    var defaultSafeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
    }
}
