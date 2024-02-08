//
//  SwatchView.swift
//  Parra
//
//  Created by Mick MacCallum on 1/22/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SwatchView: View {
    var swatch: ParraColorSwatch

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(swatch.name ?? "From \(swatch.shade500.hex())")
                .font(.callout)
                .fontWeight(.semibold)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(swatch.allShades, id: \.1) { shade in
                        let (name, color) = shade

                        VStack(alignment: .center) {
                            Text(color.hex())
                                .font(.caption2)
                                .frame(width: 60, height: 60)
                                .background(color)
                                .foregroundStyle(
                                    color
                                        .isLight() ? .black : .white
                                )

                            Text(name)
                                .font(.caption)
                        }
                    }
                }
            }
        }
    }
}

#Preview() {
    Group {
        SwatchView(swatch: .init(primary: .accentColor, name: "A swatch name"))
            .padding()

        SwatchView(swatch: .amber)
            .padding()
    }
}
