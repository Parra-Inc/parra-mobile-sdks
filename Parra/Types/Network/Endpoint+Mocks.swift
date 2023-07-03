//
//  Endpoint+Mocks.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

// TODO: Example objects for each of these
extension ParraEndpoint {
    func getMockResponseData() throws -> Data {
        let object: Codable
        switch self {
        case .getCards:
            object = EmptyResponseObject()
        case .getFeedbackForm(let formId):
            object = EmptyResponseObject()
        case .postSubmitFeedbackForm(let formId):
            object = EmptyResponseObject()
        case .postBulkAnswerQuestions:
            object = EmptyResponseObject()
        case .postBulkSubmitSessions(let tenantId):
            object = EmptyResponseObject()
        case .postPushTokens(let tenantId):
            object = EmptyResponseObject()
        case .postAuthentication(let tenantId):
            object = EmptyResponseObject()
        }

        return try JSONEncoder.parraEncoder.encode(object)
    }
}
