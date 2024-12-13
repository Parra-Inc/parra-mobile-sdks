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
                    width: 17,
                    height: 17
                )
                .tint(
                    theme.palette.primary.shade600
                )
                .aspectRatio(contentMode: .fit)
        }
        .padding(
            .padding(
                top: 4.5,
                leading: 11.5,
                bottom: 3.5,
                trailing: 9
            )
        )
        .background(
            theme.palette.primary.shade300
        )
        .applyCornerRadii(size: .full, from: theme)
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
}
