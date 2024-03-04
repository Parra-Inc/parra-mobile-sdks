//
//  WidgetFooter.swift
//  Parra
//
//  Created by Mick MacCallum on 3/2/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct WidgetFooter: View {
    // MARK: - Lifecycle

    init(
        primaryActionBuilder: @escaping () -> any View,
        secondaryActionBuilder: (() -> any View)? = nil,
        contentPadding: EdgeInsets = EdgeInsets(vertical: 12, horizontal: 20)
    ) {
        self.primaryActionBuilder = primaryActionBuilder
        self.secondaryActionBuilder = secondaryActionBuilder
        self.contentPadding = contentPadding
    }

    // MARK: - Internal

    @ViewBuilder let primaryActionBuilder: () -> any View
    @ViewBuilder let secondaryActionBuilder: (() -> any View)?

    @EnvironmentObject var themeObserver: ParraThemeObserver

    var body: some View {
        VStack(alignment: .center, spacing: 16) {
            AnyView(primaryActionBuilder())

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
            color: themeObserver.theme.palette.secondaryBackground
        )
    }

    // MARK: - Private

    private let contentPadding: EdgeInsets
}
