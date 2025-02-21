//
//  View+upsideDown.swift
//  Parra
//
//  Created by Mick MacCallum on 2/20/25.
//

import SwiftUI

struct UpsideDown: ViewModifier {
    func body(
        content: Content
    ) -> some View {
        content
            .rotationEffect(
                .radians(.pi)
            )
            .scaleEffect(
                x: -1,
                y: 1,
                anchor: .center
            )
    }
}

extension View {
    func upsideDown() -> some View {
        modifier(UpsideDown())
    }
}
