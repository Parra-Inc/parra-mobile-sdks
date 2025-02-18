//
//  ChannelNavigationHeaderView.swift
//  Parra
//
//  Created by Mick MacCallum on 2/13/25.
//

import SwiftUI

struct ChannelNavigationHeaderView: View {
    // MARK: - Internal

    var user: ParraUserStub

    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            componentFactory.buildLabel(
                text: user.displayName,
                localAttributes: ParraAttributes.Label(
                    text: .default(with: .headline),
                    padding: .zero
                )
            )

            if let verified = user.verified, verified, redactionReasons.isEmpty {
                componentFactory.buildImage(
                    content: .name("CheckBadgeSolid", .module, .template),
                    localAttributes: ParraAttributes.Image(
                        tint: .blue,
                        size: CGSize(width: 20, height: 20),
                        padding: .zero
                    )
                )
            }

            if let role = user.roles?.elements.first, redactionReasons.isEmpty {
                componentFactory.buildLabel(
                    text: role.name,
                    localAttributes: ParraAttributes.Label(
                        text: .init(
                            style: .caption2,
                            color: theme.palette.primary.toParraColor()
                        ),
                        cornerRadius: .sm,
                        padding: .custom(
                            EdgeInsets(vertical: 2.5, horizontal: 7)
                        ),
                        background: theme.palette.primary
                            .toParraColor()
                            .opacity(0.2)
                    )
                )
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.redactionReasons) private var redactionReasons
}
