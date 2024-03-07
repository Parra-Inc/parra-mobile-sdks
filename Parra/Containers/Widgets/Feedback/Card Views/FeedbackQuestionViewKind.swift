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
    var question: Question { get }
    var themeObserver: ParraThemeObserver { get }
    var contentObserver: FeedbackCardWidget.ContentObserver { get }
    var localBuilderConfig: FeedbackCardWidgetBuilderConfig { get }
    var componentFactory: ComponentFactory { get }
    var config: FeedbackCardWidgetConfig { get }

    init(
        bucketId: String,
        question: Question,
        data: DataType
    )

    func shouldAllowCommittingSelection() -> Bool
}

extension FeedbackQuestionViewKind {
    func shouldAllowCommittingSelection() -> Bool {
        return true
    }
}
