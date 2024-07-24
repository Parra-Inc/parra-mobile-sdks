//
//  ParraQuestionHandlerDelegate.swift
//  Parra
//
//  Created by Mick MacCallum on 2/27/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

protocol ParraQuestionHandlerDelegate: AnyObject {
    /// Not meant to be triggered during every selection event. Just when a new selection occurs that may be
    /// required to cause a transition or other side effects.
    func questionHandlerDidMakeNewSelection(
        forQuestion question: Question
    ) async
}
