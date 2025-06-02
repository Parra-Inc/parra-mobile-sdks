//
//  Color+hex.swift
//  Parra
//
//  Created by Mick MacCallum on 1/20/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation
import SwiftUI

extension Color {
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

    /// Initializes a String from a hexadecimal string representation.
    ///
    /// - Parameter hex: The hexadecimal string to convert.
    /// - Returns: A new String initialized from the hexadecimal representation,
    ///            or an empty string if the input is not a valid hex string.
    public static func fromHex(_ hex: String) -> Color {
        var cString: String = hex.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).uppercased()

        if cString.hasPrefix("#") {
            cString.remove(at: cString.startIndex)
        }

        // Ensure the hex string has an even number of characters
        guard hex.count % 2 == 0 else {
            return .black
        }

        let r, g, b, a: UInt64

        let start = hex.index(hex.startIndex, offsetBy: 1)
        let hexColor = String(hex[start...])

        if hexColor.count >= 6 {
            let scanner = Scanner(string: hexColor)
            var hexNumber: UInt64 = 0

            if scanner.scanHexInt64(&hexNumber) {
                r = hexNumber & 0xFF00_0000 >> 24
                g = hexNumber & 0x00FF_0000 >> 16
                b = hexNumber & 0x0000_FF00 >> 8

                if hexColor.count > 6 {
                    a = hexNumber & 0x0000_00FF
                } else {
                    a = 255
                }

                return Color(
                    red: Int(r),
                    green: Int(g),
                    blue: Int(b),
                    opacity: CGFloat(a) / 255
                )
            }
        }

        return .black
    }

    func hex(
        withHashPrefix: Bool = true
    ) -> String {
        var (r, g, b, a): (CGFloat, CGFloat, CGFloat, CGFloat) = (
            0.0,
            0.0,
            0.0,
            0.0
        )

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
