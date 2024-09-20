//
//  EnvironmentValues+defaultSafeAreaInsets.swift
//
//
//  Created by Mick MacCallum on 9/20/24.
//

import SwiftUI

private struct SafeAreaInsetsKey: EnvironmentKey {
    @MainActor static var defaultValue: EdgeInsets {
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
