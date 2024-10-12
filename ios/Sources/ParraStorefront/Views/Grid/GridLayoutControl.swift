//
//  GridLayoutControl.swift
//  Parra
//
//  Created by Mick MacCallum on 9/30/24.
//

import SwiftUI

struct GridLayoutControl: View {
    @Binding var selectedLayout: GridLayout

    var body: some View {
        Picker("Grid Layout", selection: $selectedLayout) {
            ForEach(GridLayout.allCases, id: \.self) { layout in
                Image(systemName: layout.icon)
                    .tag(layout)
            }
        }
    }
}
