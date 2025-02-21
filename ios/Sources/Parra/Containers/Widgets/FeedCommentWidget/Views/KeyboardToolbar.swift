//
//  KeyboardToolbar.swift
//  Parra
//
//  Created by Mick MacCallum on 12/17/24.
//

import SwiftUI

struct KeyboardToolbar<ToolbarView: View>: ViewModifier {
    // MARK: - Lifecycle

    init(height: CGFloat, @ViewBuilder toolbar: () -> ToolbarView) {
        self.height = height
        self.toolbarView = toolbar()
    }

    // MARK: - Internal

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    content
                }
                .frame(
                    width: geometry.size.width,
                    height: geometry.size.height - height
                )
            }

            toolbarView
                .frame(height: height)
                .background(
                    theme.palette.primaryBackground
                )
        }
    }

    // MARK: - Private

    private let height: CGFloat
    private let toolbarView: ToolbarView

    @Environment(\.parraTheme) private var theme
}

extension View {
    func keyboardToolbar(
        height: CGFloat,
        view: @escaping () -> some View
    ) -> some View {
        modifier(
            KeyboardToolbar(
                height: height,
                toolbar: view
            )
        )
    }
}
