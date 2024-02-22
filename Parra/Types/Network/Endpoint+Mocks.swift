//
//  Endpoint+Mocks.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ParraEndpoint {
    func getMockResponseData(for status: Int = 200) throws -> Data {
        let object: Codable
        switch status {
        case 200 ..< 300:
            switch self {
            case .getCards:
                object = ParraCardItemFixtures.cardsResponse
            case .getFeedbackForm(let formId):
                object = TestData.Forms.formResponse(formId: formId)
            case .postSubmitFeedbackForm:
                object = EmptyResponseObject()
            case .postBulkAnswerQuestions:
                object = EmptyResponseObject()
            case .postBulkSubmitSessions:
                object = TestData.Sessions.successResponse
            case .postPushTokens:
                object = EmptyResponseObject()
            case .postAuthentication:
                object = TestData.Auth.successResponse
            }
        default:
            throw ParraError.generic(
                "getMockResponseData has no implemented return for status: \(status) for endpoint: \(slug)",
                nil
            )
        }

        return try JSONEncoder.parraEncoder.encode(object)
    }
}
