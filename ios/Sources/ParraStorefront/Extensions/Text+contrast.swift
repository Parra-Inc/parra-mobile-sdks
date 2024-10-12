//
//  Text+contrast.swift
//  Parra
//
//  Created by Mick MacCallum on 10/12/24.
//

import SwiftUI

extension Text {
    func contrastingForegroundColor(
        to backgroundColor: Color,
        darkColor: Color = .black,
        lightColor: Color = .white
    ) -> some View {
        var r, g, b, a: CGFloat
        (r, g, b, a) = (0, 0, 0, 0)

        UIColor(backgroundColor).getRed(&r, green: &g, blue: &b, alpha: &a)

        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b

        if luminance < 0.6 {
            return foregroundColor(lightColor)
        } else {
            return foregroundColor(darkColor)
        }
    }
}
