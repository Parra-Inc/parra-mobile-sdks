//
//  ColorPaletteView.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct PaletteView: View {
    var palette: [ParraColorSwatch]

    var body: some View {
        VStack(alignment: .leading) {
            Text("Theme Swatches")
                .font(.largeTitle)
                .bold()
                .padding()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(palette, id: \.self) { swatch in
                        SwatchView(swatch: swatch)
                            .padding(.bottom)
                    }
                }
            }
        }
        .padding()
        .background(.background)
    }
}

#Preview("Standard Palette") {
    let palette = ParraColorPalette.default

    return PaletteView(
        palette: [
            palette.primary,
            palette.secondary,
            palette.info,
            palette.warning,
            palette.error,
            palette.success
        ]
    )
}

#Preview("Full Standard Color Palette") {
    return PaletteView(
        palette: ParraColorSwatch.standardSwatches
    )
}
