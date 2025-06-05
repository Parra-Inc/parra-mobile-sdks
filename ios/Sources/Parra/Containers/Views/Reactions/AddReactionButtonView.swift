//
//  AddReactionButtonView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI

struct AddReactionButtonView: View {
    // MARK: - Internal

    let attachmentPaywall: ParraAppPaywallConfiguration?
    let onAddReaction: () -> Void

    @ViewBuilder var image: some View {
        if userEntitlements.hasEntitlement(attachmentPaywall?.entitlement) {
            Image(
                uiImage: UIImage(
                    named: "custom.face.smiling.badge.plus",
                    in: .module,
                    with: nil
                )!
            )
            .resizable()
            .renderingMode(.template)
            .frame(
                width: 18,
                height: 18
            )
            .foregroundStyle(
                theme.palette.secondaryChipText.toParraColor()
            )
            .aspectRatio(contentMode: .fit)
            .padding(
                .padding(
                    top: 5.5,
                    leading: 13.5,
                    bottom: 4.5,
                    trailing: 11
                )
            )
        } else {
            Image(
                uiImage: UIImage(systemName: "lock.circle")!
            )
            .renderingMode(.template)
            .frame(
                height: 18
            )
            .aspectRatio(contentMode: .fit)
            .tint(
                theme.palette.secondaryChipText.toParraColor()
            )
            .padding(
                .padding(
                    top: 5,
                    leading: 12,
                    bottom: 5,
                    trailing: 12
                )
            )
        }
    }

    var body: some View {
        Button {
            onAddReaction()
        } label: {
            image
        }
        .background(
            theme.palette.secondaryChipBackground.toParraColor()
        )
        .applyCornerRadii(size: .full, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraUserEntitlements) private var userEntitlements
}
