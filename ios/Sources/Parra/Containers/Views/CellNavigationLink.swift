//
//  CellNavigationLink.swift
//  Parra
//
//  Created by Mick MacCallum on 2/24/25.
//

import SwiftUI

struct CellNavigationLink<Label, P>: View where Label: View, P: Hashable {
    var value: P?
    @ViewBuilder var label: () -> Label

    var body: some View {
        NavigationLink(
            value: value,
            label: label
        )
        // Required to prevent highlighting the button then dragging the scroll
        // view from causing the button to be pressed.
        .simultaneousGesture(TapGesture())
    }
}
