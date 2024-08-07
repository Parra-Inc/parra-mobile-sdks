//
//  FeedbackFormSubmissionType.swift
//  Parra
//
//  Created by Mick MacCallum on 3/5/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import Foundation

enum FeedbackFormSubmissionType {
    case `default`
    case custom(([ParraFeedbackFormField: String]) async -> Void)
}
