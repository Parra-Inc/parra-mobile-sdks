//
//  CameraPermissionDeniedView.swift
//  Parra
//
//  Created by Mick MacCallum on 6/6/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct CameraPermissionDeniedView: View {
    // MARK: - Internal

    var body: some View {
        VStack(spacing: 10) {
            componentFactory.buildImage(
                content: .symbol("camera"),
                localAttributes: ParraAttributes.Image(
                    tint: parraTheme.palette.primary.toParraColor(),
                    size: CGSize(width: 100, height: 100)
                )
            )
            .padding(.bottom, 12)

            componentFactory.buildLabel(
                text: "Allow camera access",
                localAttributes: .default(with: .title2)
            )

            componentFactory.buildLabel(
                text: "We need access to your camera to take a new profile picture. You can enable camera access in your settings.",
                localAttributes: .default(with: .body)
            )

            Link(
                destination: URL(string: UIApplication.openSettingsURLString)!
            ) {
                componentFactory.buildLabel(
                    text: "Open settings",
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .callout,
                            color: parraTheme.palette.primary
                                .toParraColor()
                        )
                    )
                )
            }
            .padding(.top, 20)
        }
    }

    // MARK: - Private

    @Environment(ParraComponentFactory.self) private var componentFactory

    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { _ in
        CameraPermissionDeniedView()
            .padding()
    }
}
