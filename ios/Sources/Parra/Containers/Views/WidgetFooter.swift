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
        @ViewBuilder primaryActionBuilder: @escaping () -> Primary,
        secondaryActionBuilder: (() -> any View)? = nil,
        contentPadding: EdgeInsets = EdgeInsets(vertical: 12, horizontal: 20)
    ) {
        self.primaryActionBuilder = primaryActionBuilder
        self.secondaryActionBuilder = secondaryActionBuilder
        self.contentPadding = contentPadding
    }

    // MARK: - Internal

    @ViewBuilder let primaryActionBuilder: () -> Primary
    @ViewBuilder let secondaryActionBuilder: (() -> any View)?

    var body: some View {
        if let primaryAction = primaryActionBuilder() as? AnyView {
            VStack(alignment: .center, spacing: 16) {
                primaryAction

                if let secondaryActionBuilder {
                    AnyView(secondaryActionBuilder())
                } else {
                    ParraLogoButton(type: .poweredBy)
                }
            }
            .frame(maxWidth: .infinity)
            .padding([.leading, .trailing, .bottom], from: contentPadding)
            // Using the leading padding of the container as the footer's top
            // padding to keep the button square with its container
            .padding(.top, contentPadding.leading)
            .border(
                width: 1,
                edges: .top,
                color: parraTheme.palette.secondarySeparator.toParraColor()
            )
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var parraTheme

    private let contentPadding: EdgeInsets
}
