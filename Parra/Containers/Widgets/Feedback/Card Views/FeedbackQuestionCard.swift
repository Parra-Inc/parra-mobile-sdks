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

    let bucketId: String
    let question: Question

    var body: some View {
        VStack {
            Text(question.title)

            bodyByQuestionKind
        }
    }

    // MARK: - Private

    @ViewBuilder private var bodyByQuestionKind: some View {
        switch question.data {
        case .choiceQuestionBody(let choiceQuestionBody):
            Text(choiceQuestionBody.options.description)
        case .checkboxQuestionBody(let checkboxQuestionBody):
            Text(checkboxQuestionBody.options.description)
        case .imageQuestionBody(let imageQuestionBody):
            Text(imageQuestionBody.options.description)
        case .ratingQuestionBody(let ratingQuestionBody):
            Text(ratingQuestionBody.options.description)
        case .starQuestionBody(let starQuestionBody):
            Text(String(describing: starQuestionBody))
        case .shortTextQuestionBody(let shortTextQuestionBody):
            Text(String(describing: shortTextQuestionBody))
        case .longTextQuestionBody(let longTextQuestionBody):
            Text(String(describing: longTextQuestionBody))
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
