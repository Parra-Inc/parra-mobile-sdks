//
//  SubmissionOptions+SubmissionOptionInfo.swift
//  Parra
//
//  Created by Mick MacCallum on 7/17/24.
//  Copyright © 2024 Parra, Inc. All rights reserved.
//

import SwiftUI

extension SubmissionOptions {
    struct SubmissionOptionInfo: Identifiable, Hashable {
        let content: TextButtonContent
        let onPress: () async -> Void

        var id: String {
            return content.text.text
        }

        static func == (
            lhs: SubmissionOptions.SubmissionOptionInfo,
            rhs: SubmissionOptions.SubmissionOptionInfo
        ) -> Bool {
            return lhs.content == rhs.content
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(content)
            hasher.combine(id)
        }
    }
}
