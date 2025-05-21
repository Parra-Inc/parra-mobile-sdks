//
//  ParraMediaAwareScrollView.swift
//  Parra
//
//  Created by Mick MacCallum on 5/20/25.
//

import SwiftUI

public struct ParraMediaAwareScrollView<Content>: View where Content: View {
    // MARK: - Lifecycle

    public init(
        axes: Axis.Set = .vertical,
        additionalScrollContentMargins: EdgeInsets = .init(),
        additionalScrollIndicatorMargins: EdgeInsets = .init(),
        inverted: Bool = false,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.axes = axes
        self.additionalScrollContentMargins = additionalScrollContentMargins
        self.additionalScrollIndicatorMargins = additionalScrollIndicatorMargins
        self.inverted = inverted
        self.content = content
    }

    // MARK: - Public

    public var body: some View {
        ScrollView(axes, content: content)
            .contentMargins(
                .all,
                contentMargins,
                for: .scrollContent
            )
            .contentMargins(
                .all,
                indicatorMargins,
                for: .scrollIndicators
            )
    }

    // MARK: - Private

    private var axes: Axis.Set
    private var additionalScrollContentMargins: EdgeInsets
    private var additionalScrollIndicatorMargins: EdgeInsets
    private var inverted: Bool

    @ViewBuilder private var content: () -> Content

    @State private var player = MediaPlaybackManager.shared

    private var mediaPlayerMargin: Double {
        let base = inverted ? additionalScrollContentMargins
            .top : additionalScrollContentMargins.bottom
        let safeAreaAware: Double = base == 0 ? 120 : 86 // without safe area

        return base + safeAreaAware
    }

    private var contentMargins: EdgeInsets {
        return EdgeInsets(
            top: inverted ? mediaPlayerMargin : additionalScrollContentMargins.top,
            leading: additionalScrollContentMargins.leading,
            bottom: inverted ? additionalScrollContentMargins.bottom : mediaPlayerMargin,
            trailing: additionalScrollContentMargins.trailing
        )
    }

    private var indicatorMargins: EdgeInsets {
        return EdgeInsets(
            top: additionalScrollIndicatorMargins.top,
            leading: additionalScrollIndicatorMargins.leading,
            bottom: additionalScrollIndicatorMargins.bottom,
            trailing: additionalScrollIndicatorMargins.trailing
        )
    }
}
