//
//  Endpoint+Mocks.swift
//  Parra
//
//  Created by Mick MacCallum on 7/2/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation

extension ApiEndpoint {
    func getMockResponseData(for status: Int = 200) throws -> Data {
        let object: Codable = switch status {
        case 200 ..< 300:
            switch self {
            case .getCards:
                ParraCardItemFixtures.cardsResponse
            case .getFeedbackForm(let formId):
                ParraFeedbackForm.testForm(with: formId)
            case .postSubmitFeedbackForm:
                EmptyResponseObject()
            case .postBulkAnswerQuestions:
                EmptyResponseObject()
            case .postBulkSubmitSessions:
                ParraSessionsResponse.successResponse
            case .postPushTokens:
                EmptyResponseObject()
            case .getRoadmap:
                ParraAppRoadmapConfiguration.validStates()[0]
            case .getPaginateTickets:
                ParraUserTicketCollectionResponse.validStates()[0]
            case .postVoteForTicket:
                ParraUserTicket.validStates()[0]
            case .deleteVoteForTicket:
                ParraUserTicket.validStates()[0]
            case .getRelease:
                ParraAppRelease.validStates()[0]
            case .getPaginateReleases:
                AppReleaseCollectionResponse.validStates()[0]
            case .getAppInfo:
                ParraAppInfo.validStates()[0]
            default:
                fatalError()
            }
        default:
            throw ParraError.generic(
                "getMockResponseData has no implemented return for status: \(status) for endpoint: \(slug)",
                nil
            )
        }

        return try JSONEncoder.parraEncoder.encode(object)
    }

    /// For 3rd party or non Parra endpoint URLs.
    static func getMock3rdPartyResponseData(
        for url: URL,
        status: Int = 200
    ) throws -> Data {
        let absoluteUrl = url.absoluteString

        let object: Codable = if absoluteUrl
            .contains("itunes.apple.com/us/lookup")
        {
            AppInfoManager.AppStoreResponse.validStates()[0]
        } else {
            throw ParraError.generic(
                "getMockResponseData has no implemented return for status: \(status) for url: \(absoluteUrl)",
                nil
            )
        }

        return try JSONEncoder().encode(object)
    }
}
