//
//  FeedbackQuestionCard.swift
//  Parra
//
//  Created by Mick MacCallum on 2/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

struct FeedbackQuestionCard: View {
    // MARK: - Internal

    @Environment(FeedbackCardWidgetConfig.self) var config
    @Environment(FeedbackCardWidgetBuilderConfig.self) var localBuilderConfig
    @EnvironmentObject var componentFactory: ComponentFactory

    let bucketId: String
    let question: Question

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 2) {
                componentFactory.buildLabel(
                    config: config.titleLabel,
                    content: LabelContent(text: question.title),
                    suppliedBuilder: localBuilderConfig.title
                )
                .minimumScaleFactor(0.8)
                .lineLimit(2)
                .truncationMode(.tail)
                .fixedSize(horizontal: false, vertical: true)
                .layoutPriority(100)

                if let subtitle = question.subtitle {
                    componentFactory.buildLabel(
                        config: config.subtitleLabel,
                        content: LabelContent(text: subtitle),
                        suppliedBuilder: localBuilderConfig.subtitle
                    )
                    .minimumScaleFactor(0.8)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .fixedSize(horizontal: false, vertical: true)
                    .layoutPriority(90)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
                .layoutPriority(1)

            bodyByQuestionKind

            Spacer()
                .layoutPriority(1)
        }
    }

    // MARK: - Private

    @ViewBuilder private var bodyByQuestionKind: some View {
        switch question.data {
        case .choiceQuestionBody(let data):
            composeCard(
                with: FeedbackChoiceQuestionCard.self,
                data: data
            )
        case .checkboxQuestionBody(let data):
            composeCard(
                with: FeedbackCheckboxQuestionCard.self,
                data: data
            )
        case .imageQuestionBody(let data):
            Text(data.options.first!.title!)
        case .ratingQuestionBody(let data):
            Text(data.options.first!.title)
        case .starQuestionBody(let data):
            Text(String(describing: data))
        case .shortTextQuestionBody(let data):
            Text(String(describing: data))
        case .longTextQuestionBody(let data):
            Text(String(describing: data))
        case .booleanQuestionBody(let data):
            composeCard(
                with: FeedbackBooleanQuestionCard.self,
                data: data
            )
        }
    }

    private func composeCard<T>(
        with type: T.Type,
        data: T.DataType
    ) -> some View where T: FeedbackQuestionViewKind {
        return T(
            bucketId: bucketId,
            question: question,
            data: data
        )
    }
}

#Preview {
    ParraCardViewPreview {
        FeedbackQuestionCard(
            bucketId: UUID().uuidString,
            question: ParraCardItemFixtures.boolQuestion
        )
    }
}
