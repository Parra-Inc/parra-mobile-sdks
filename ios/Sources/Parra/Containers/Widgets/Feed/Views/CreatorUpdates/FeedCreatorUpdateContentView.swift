//
//  FeedCreatorUpdateContentView.swift
//  Parra
//
//  Created by Mick MacCallum on 12/16/24.
//

import SwiftUI

struct FeedCreatorUpdateContentView: View {
    // MARK: - Internal

    let creatorUpdate: ParraCreatorUpdateAppStub

    var body: some View {
        VStack(spacing: 0) {
            withContent(content: creatorUpdate.title) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .headline
                        ),
                        padding: .custom(
                            EdgeInsets(top: 6, leading: 0, bottom: 0, trailing: 0)
                        ),
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )
            }

            withContent(content: creatorUpdate.body) { content in
                componentFactory.buildLabel(
                    text: content,
                    localAttributes: ParraAttributes.Label(
                        text: ParraAttributes.Text(
                            style: .body
                        ),
                        padding: .custom(
                            EdgeInsets(top: 3, leading: 0, bottom: 6, trailing: 0)
                        ),
                        frame: .flexible(
                            FlexibleFrameAttributes(
                                maxWidth: .infinity,
                                alignment: .leading
                            )
                        )
                    )
                )
                .lineLimit(8)
            }
        }
    }

    // MARK: - Private

    @Environment(\.parraComponentFactory) private var componentFactory
    @Environment(\.parraTheme) private var parraTheme
}
