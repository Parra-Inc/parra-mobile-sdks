//
//  RecentLogViewer.swift
//  Parra
//
//  Created by Mick MacCallum on 3/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

private let palette = ParraTheme.default.palette

struct RecentLogViewer: View {
    // MARK: - Internal

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(debugLogStore.logs) { log in
                    LogView(log: log)
                }
            }
        }
        .contentMargins(20, for: .scrollContent)
        .background(palette.primaryBackground)
    }

    // MARK: - Private

    @State private var debugLogStore = DebugLogStore.shared
}

#Preview {
    RecentLogViewer()
}
