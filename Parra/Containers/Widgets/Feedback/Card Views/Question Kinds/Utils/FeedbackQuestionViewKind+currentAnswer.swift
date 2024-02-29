//
//  FeedbackQuestionViewKind+currentAnswer.swift
//  Parra
//
//  Created by Mick MacCallum on 2/29/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension FeedbackQuestionViewKind {
    @MainActor var currentAnswer: AnswerType? {
        return contentObserver.currentAnswer(for: bucketId)
    }
}
