//
//  LogView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let palette = ParraTheme.default.palette

struct LogView: View {
    let log: DebugLogStore.UniqueLog

    var body: some View {
        VStack(alignment: .leading) {
            Text(log.timestamp)
                .font(.caption)
                .foregroundStyle(palette.secondaryText.toParraColor())

            Text(log.message)
                .font(.footnote)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.secondaryBackground)
        .applyCornerRadii(size: .md, from: .default)
    }
}
