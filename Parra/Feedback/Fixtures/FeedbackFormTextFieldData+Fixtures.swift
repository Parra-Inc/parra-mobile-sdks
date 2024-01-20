//
//  FeedbackFormTextFieldData+Fixtures.swift
//  Parra
//
//  Created by Mick MacCallum on 1/18/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

extension FeedbackFormTextFieldData: ParraFixture {
    static func validStates() -> [FeedbackFormTextFieldData] {
        return [
            FeedbackFormTextFieldData(
                placeholder: "placeholder",
                lines: 5,
                maxLines: 10,
                minCharacters: 20,
                maxCharacters: 420,
                maxHeight: 200
            )
        ]
    }

    static func invalidStates() -> [FeedbackFormTextFieldData] {
        return []
    }
}
