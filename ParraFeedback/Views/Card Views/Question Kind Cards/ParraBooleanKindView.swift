//
//  ParraBooleanKindView.swift
//  ParraFeedback
//
//  Created by Mick MacCallum on 2/18/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import UIKit
import ParraCore

// "boolean" means single selection from two options
internal class ParraBooleanKindView: UIView, ParraQuestionKindView {
    typealias DataType = BooleanQuestionBody
    typealias AnswerType = SingleOptionAnswer

    private let data: DataType
    private let answerHandler: ParraAnswerHandler

    required init(
        question: Question,
        data: DataType,
        config: ParraCardViewConfig,
        answerHandler: ParraAnswerHandler
    ) {
        self.data = data
        self.answerHandler = answerHandler

        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal func applyConfig(_ config: ParraCardViewConfig) {
        
    }
}

