//
//  ParraLabel.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraLabel: View, ParraConfigurableView {
    let text: String
    let viewConfig: ParraLabelViewConfig

    @ViewBuilder
    var body: some View {
        Text(text)
            .applyViewConfig(viewConfig)
    }
}

#Preview {
    let theme = ParraTheme.default

    return VStack(alignment: .leading, spacing: 15) {
        ParraLabel(
            text: "Default config",
            viewConfig: theme.defaultLabelViewConfig()
        )

        ParraLabel(
            text: "A large title!",
            viewConfig: .init(
                font: .largeTitle.bold(),
                color: .black,
                background: nil,
                cornerRadius: .zero,
                padding: .zero
            )
        )

        ParraLabel(
            text: "A subheadline",
            viewConfig: .init(
                font: .subheadline,
                color: .gray,
                background: nil,
                cornerRadius: .zero,
                padding: .zero
            )
        )

        ParraLabel(
            text: "With a background",
            viewConfig: .init(
                font: .title,
                color: .green,
                background: .color(.red),
                cornerRadius: .zero,
                padding: .zero
            )
        )

        ParraLabel(
            text: "With a background gradient",
            viewConfig: .init(
                font: .title,
                color: .white,
                background: .gradient(.init(colors: [.pink, .purple])),
                cornerRadius: .init(allCorners: 4),
                padding: .init(top: 4, leading: 10, bottom: 4, trailing: 10)
            )
        )

        ParraLabel(
            text: "With corner radius",
            viewConfig: .init(
                font: .subheadline,
                color: .gray,
                background: .color(.green),
                cornerRadius: .init(allCorners: 12),
                padding: .init(top: 6, leading: 6, bottom: 6, trailing: 6)
            )
        )
    }
}
