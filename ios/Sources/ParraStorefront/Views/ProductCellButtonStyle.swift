//
//  ProductCellButtonStyle.swift
//  KbIosApp
//
//  Created by Mick MacCallum on 10/1/24.
//

import SwiftUI

struct ProductCellButtonStyle: ButtonStyle {
    public func makeBody(
        configuration: Self.Configuration
    ) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.8 : 1)
            .scaleEffect(configuration.isPressed ? 1.015 : 1)
            .animation(
                .linear(duration: 0.1),
                value: configuration.isPressed
            )
    }
}
