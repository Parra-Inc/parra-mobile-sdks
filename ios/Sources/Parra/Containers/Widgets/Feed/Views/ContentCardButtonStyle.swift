//
//  ContentCardButtonStyle.swift
//  Parra
//
//  Created by Mick MacCallum on 9/26/24.
//

import SwiftUI

struct ContentCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            // required to prevent tapping outside of the button from triggering it
            .clipShape(Rectangle()).buttonStyle(.borderless)
            .foregroundStyle(Color.accentColor)
            .opacity(configuration.isPressed ? 0.75 : 1)
            .animation(.default, value: configuration.isPressed)
    }
}
