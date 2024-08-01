//
//  UIApplication+resignFirstResponder.swift
//  Parra
//
//  Created by Mick MacCallum on 6/26/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import UIKit

extension UIApplication {
    static func resignFirstResponder() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}
