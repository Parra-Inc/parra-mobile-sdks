//
//  ParraEndpoint.swift
//  ParraTests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraEndpoint: CaseIterable {
    public static var allCases: [ParraEndpoint] = {
        let testCases: [ParraEndpoint] = [
            .getCards,
            .getFeedbackForm(formId: ""),
            .postAuthentication(tenantId: ""),
            .postBulkAnswerQuestions,
            .postBulkSubmitSessions(tenantId: ""),
            .postPushTokens(tenantId: ""),
            .postSubmitFeedbackForm(formId: "")
        ]

        // We can't automatically synthesize CaseIterable conformance, so we're
        // providing the list manually. We hard code the list then iterate through
        // it to ensure compiler errors here if new cases are added. Performance doesn't
        // matter since this only runs once, and only when running tests.

        var finalCases = [ParraEndpoint]()
        for testCase in testCases {
            switch testCase {
            case .postAuthentication:
                finalCases.append(testCase)
            case .getCards:
                finalCases.append(testCase)
            case .getFeedbackForm:
                finalCases.append(testCase)
            case .postSubmitFeedbackForm:
                finalCases.append(testCase)
            case .postBulkAnswerQuestions:
                finalCases.append(testCase)
            case .postBulkSubmitSessions:
                finalCases.append(testCase)
            case .postPushTokens:
                finalCases.append(testCase)
            }
        }

        return finalCases
    }()
}
