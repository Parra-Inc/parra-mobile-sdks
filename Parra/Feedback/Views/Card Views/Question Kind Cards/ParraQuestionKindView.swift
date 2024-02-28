//
//  ParraQuestionKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/12/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

protocol ParraQuestionOption: Identifiable {
    var id: String { get }
    var title: String { get }
    var value: String { get }
}

// All ParraQuestionKindView's need to internally manage the selection/deselection of
// whatever views they need to render while distilling state updates to those consumable
// by the ParraCardAnswerHandler.
protocol ParraQuestionKindView: ParraConfigurableCardView {
    associatedtype DataType
    associatedtype AnswerType

    init(
        bucketId: String,
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraCardAnswerHandler
    )

    func shouldAllowCommittingSelection() -> Bool
}

extension ParraQuestionKindView {
    func shouldAllowCommittingSelection() -> Bool {
        return true
    }
}
