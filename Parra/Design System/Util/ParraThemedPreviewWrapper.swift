//
//  ParraThemedPreviewWrapper.swift
//  Parra
//
//  Created by Mick MacCallum on 2/8/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct ParraThemedPreviewWrapper<T: View>: View {
    // MARK: - Lifecycle

    init(
        theme: ParraTheme = .default,
        @ViewBuilder content: @escaping () -> T
    ) {
        self.contentBuilder = content
        _themeObserver = StateObject(
            wrappedValue: ParraThemeObserver(
                theme: theme,
                notificationCenter: ParraNotificationCenter()
            )
        )
    }

    // MARK: - Internal

    var body: some View {
        AnyView(
            contentBuilder()
                .environmentObject(themeObserver)
        )
    }

    // MARK: - Private

    @StateObject private var themeObserver: ParraThemeObserver
    private var contentBuilder: () -> T
}
