//
//  ParraView.swift
//  Parra
//
//  Created by Mick MacCallum on 1/23/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraView: View, ParraConfigurableView {
    let viewConfig: ParraViewConfig

    var body: some View {
        Color(.clear)
            .applyViewConfig(viewConfig)
    }
}

#Preview {
    let theme = ParraTheme.default
    
    return VStack(alignment: .center, spacing: 0) {
        ParraView(
            viewConfig: .init(
                background: .color(.pink),
                cornerRadius: .init(
                    topLeading: 20,
                    bottomLeading: 0,
                    bottomTrailing: 0,
                    topTrailing: 20
                ),
                padding: .init(top: 0, leading: 0, bottom: 6, trailing: 0)
            )
        )
        .frame(width: 100, height: 100)

        ParraView(
            viewConfig: .init(
                background: .gradient(.init(colors: [.pink, .purple])),
                cornerRadius: .zero,
                padding: .init(top: 6, leading: 0, bottom: 6, trailing: 0)
            )
        )
        .frame(width: 100, height: 100)

        ParraView(
            viewConfig: .init(
                background: .gradient(.init(colors: [.purple, .pink])),
                cornerRadius: .zero,
                padding: .init(top: 6, leading: 0, bottom: 6, trailing: 0)
            )
        )
        .frame(width: 100, height: 100)

        ParraView(
            viewConfig: .init(
                background: .color(.pink),
                cornerRadius: .init(
                    topLeading: 0,
                    bottomLeading: 20,
                    bottomTrailing: 20,
                    topTrailing: 0
                ),
                padding: .init(top: 6, leading: 0, bottom: 0, trailing: 0)
            )
        )
        .frame(width: 100, height: 100)
    }
}

