//
//  FeedbackQuestionViewKind.swift
//  Parra
//
//  Created by Mick MacCallum on 2/28/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

protocol FeedbackQuestionViewKind: View {
    associatedtype DataType
    associatedtype AnswerType: AnswerOption

    var bucketId: String { get }
    var question: ParraQuestion { get }
    var contentObserver: FeedbackCardWidget.ContentObserver { get }
    var componentFactory: ComponentFactory { get }
    var config: ParraFeedbackCardWidgetConfig { get }

    init(
        bucketId: String,
        question: ParraQuestion,
        data: DataType
    )

    func shouldAllowCommittingSelection() -> Bool
}

extension FeedbackQuestionViewKind {
    func shouldAllowCommittingSelection() -> Bool {
        return true
    }
}
