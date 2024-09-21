//
//  ParraSegmentComponent.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

public struct ParraSegmentComponent: View {
    // MARK: - Lifecycle

    init(
        config: ParraSegmentConfig,
        content: ParraSegmentContent,
        attributes: ParraAttributes.Segment
    ) {
        self.config = config
        self.content = content
        self.attributes = attributes
    }

    // MARK: - Public

    public internal(set) var config: ParraSegmentConfig
    public let content: ParraSegmentContent
    public let attributes: ParraAttributes.Segment

    public var body: some View {
        SegmentView(
            options: content.options.map { .init(id: $0.id, title: $0.text) },
            attributes: attributes,
            theme: parraTheme,
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

    @Environment(\.parraTheme) private var parraTheme
}

#Preview {
    ParraViewPreview { factory in
        factory.buildSegment(
            config: ParraSegmentConfig(),
            content: ParraSegmentContent(
                options: ParraCardItemFixtures.ratingQuestionData.options.map {
                    ParraSegmentContent.Option(
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
