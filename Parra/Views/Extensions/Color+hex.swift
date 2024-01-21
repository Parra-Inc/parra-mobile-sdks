//
//  Color+hex.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

internal extension Color {
    init(
        red: Int,
        green: Int,
        blue: Int,
        opacity: Double = 1.0
    ) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            opacity: opacity
        )
    }

    init(
        hex: Int,
        opacity: Double = 1.0
    ) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF,
            opacity: opacity
        )
    }

    func hex(
        withHashPrefix: Bool = true
    ) -> String {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 0.0)

        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)

        let prefix = withHashPrefix ? "#" : ""

        guard r.isFinite, b.isFinite, g.isFinite, a.isFinite else {
            return "\(prefix)000000"
        }

        return String(
            format: "\(prefix)%02X%02X%02X",
            Int(r * 255),
            Int(g * 255),
            Int(b * 255)
        )
    }
}
