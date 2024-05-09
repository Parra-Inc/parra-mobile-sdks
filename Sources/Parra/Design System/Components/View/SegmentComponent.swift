//
//  SegmentComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct SegmentComponent: View {
    // MARK: - Internal

    var config: SegmentConfig
    let content: SegmentContent
    let attributes: ParraAttributes.Segment

    var body: some View {
        SegmentView(
            options: content.options.map { .init(id: $0.id, title: $0.text) },
            attributes: attributes,
            theme: themeObserver.theme,
            onSelect: { option in
                content.optionSelected?(
                    .init(id: option.id, text: option.title)
                )
            },
            onConfirm: { option in
                content.optionConfirmed?(
                    .init(id: option.id, text: option.title)
                )
            }
        )
    }

    // MARK: - Private

    @EnvironmentObject private var themeObserver: ParraThemeObserver
}

#Preview {
    ParraViewPreview { factory in
        factory.buildSegment(
            config: SegmentConfig(),
            content: SegmentContent(
                options: ParraCardItemFixtures.ratingQuestionData.options.map {
                    SegmentContent.Option(
                        id: $0.id,
                        text: $0.title
                    )
                },
                optionSelected: nil,
                optionConfirmed: nil
            )
        )
    }
    .padding()
}
