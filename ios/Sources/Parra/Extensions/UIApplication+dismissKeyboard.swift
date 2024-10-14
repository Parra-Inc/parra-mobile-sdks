//
//  UIApplication+dismissKeyboard.swift
//  Parra
//
//  Created by Mick MacCallum on 6/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    /// Note: This is intentionally named differently from resignFirstResponder
    /// to avoid ambiguous contexts where the default implementation might
    /// be used instead.
    @MainActor
    static func dismissKeyboard() async {
        Task { @MainActor in
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}
