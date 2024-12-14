//
//  AddReactionButtonView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/11/24.
//

import SwiftUI

struct AddReactionButtonView: View {
    // MARK: - Internal

    let onAddReaction: () -> Void

    var body: some View {
        Button {
            onAddReaction()
        } label: {
            let image = UIImage(
                named: "custom.face.smiling.badge.plus",
                in: .module,
                with: nil
            )!

            Image(uiImage: image)
                .resizable()
                .renderingMode(.template)
                .frame(
                    width: 18,
                    height: 18
                )
                .tint(
                    theme.palette.secondaryChipText.toParraColor()
                )
                .aspectRatio(contentMode: .fit)
        }
        .padding(
            .padding(
                top: 5.5,
                leading: 13.5,
                bottom: 4.5,
                trailing: 11
            )
        )
        .background(
            theme.palette.secondaryChipBackground.toParraColor()
        )
        .applyCornerRadii(size: .full, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
