//
//  WidgetFooter.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct WidgetFooter<Primary>: View where Primary: View {
    // MARK: - Lifecycle

    init(
        @ViewBuilder primaryActionBuilder: @escaping () -> Primary?,
        secondaryActionBuilder: (() -> any View)? = nil,
        contentPadding: EdgeInsets = EdgeInsets(
            vertical: 12,
            horizontal: 20
        ),
        actionSpacing: CGFloat = 16.0
    ) {
        self.primaryActionBuilder = primaryActionBuilder
        self.secondaryActionBuilder = secondaryActionBuilder
        self.contentPadding = contentPadding
        self.actionSpacing = actionSpacing
    }

    // MARK: - Internal

    @ViewBuilder let primaryActionBuilder: () -> Primary?
    @ViewBuilder let secondaryActionBuilder: (() -> any View)?

    var body: some View {
        if let primaryAction = primaryActionBuilder() {
            VStack(spacing: contentPadding.bottom) {
                Divider()
                    .overlay(parraTheme.palette.secondarySeparator.toParraColor())

                VStack(alignment: .center, spacing: actionSpacing) {
                    primaryAction

                    if let secondaryActionBuilder {
                        AnyView(secondaryActionBuilder())
                    } else {
                        ParraLogoButton(type: .poweredBy)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding([.leading, .trailing], from: contentPadding)
            }
            .ignoresSafeArea()
            .frame(maxWidth: .infinity)
            .padding(.bottom, from: contentPadding)
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    private let contentPadding: EdgeInsets
    private let actionSpacing: CGFloat
}
