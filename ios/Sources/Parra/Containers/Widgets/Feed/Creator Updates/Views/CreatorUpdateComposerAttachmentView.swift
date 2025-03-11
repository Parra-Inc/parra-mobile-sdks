//
//  CreatorUpdateComposerAttachmentView.swift
//  Parra
//
//  Created by Mick MacCallum on 3/11/25.
//

import SwiftUI

struct CreatorUpdateComposerAttachmentView: View {
    // MARK: - Internal

    var attachment: StatefulAttachment
    var onPress: () -> Void

    var body: some View {
        Button {
            onPress()
        } label: {
            content.frame(
                width: 100,
                height: 100,
                alignment: .center
            )
            .background(
                theme.palette.secondaryBackground
            )
            .contentShape(.rect)
        }
    }

    // MARK: - Private

    @Environment(\.parraTheme) private var theme
    @Environment(\.parraComponentFactory) private var componentFactory

    @ViewBuilder private var content: some View {
        switch attachment {
        case .processing(_, let image):
            ZStack {
                if let image {
                    componentFactory.buildImage(
                        config: ParraImageConfig(
                            contentMode: .fill
                        ),
                        content: .image(image)
                    )
                }

                ProgressView()
            }
        case .uploaded(_, _, let image):
            // Even thought we just uploaded the asset, show the local one
            // for performance
            componentFactory.buildImage(
                config: ParraImageConfig(
                    contentMode: .fill
                ),
                content: .image(image)
            )
        case .errored:
            Image(systemName: "exclamationmark.triangle")
                .tint(theme.palette.error.shade400.toParraColor())
        }
    }
}
