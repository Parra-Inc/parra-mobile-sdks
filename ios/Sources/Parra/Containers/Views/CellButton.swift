//
//  CellButton.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/25.
//

import SwiftUI

struct CellButton<Label>: View where Label: View {
    var action: @MainActor () -> Void
    @ViewBuilder var label: () -> Label

    var body: some View {
        Button(
            action: action,
            label: label
        )
        .buttonStyle(ContentCardButtonStyle())
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
    }
}
