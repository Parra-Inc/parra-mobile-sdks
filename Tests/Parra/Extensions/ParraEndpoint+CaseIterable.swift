//
//  ParraEndpoint+CaseIterable.swift
//  Tests
//
//  Created by Mick MacCallum on 7/3/23.
//  Copyright © 2023 Parra, Inc. All rights reserved.
//

import Foundation
@testable import Parra

extension ApiEndpoint: CaseIterable {
    public static var allCases: [ApiEndpoint] = {
        let testCases: [ApiEndpoint] = [
            .getUserInfo,
            .getCards,
            .getFeedbackForm(formId: ""),
            .getRoadmap,
            .getPaginateTickets,
            .postLogin,
            .postLogout,
            .postBulkAnswerQuestions,
            .postBulkSubmitSessions,
            .postPushTokens,
            .postSubmitFeedbackForm(formId: ""),
            .postVoteForTicket(ticketId: ""),
            .deleteVoteForTicket(ticketId: ""),
            .getRelease(releaseId: ""),
            .getPaginateReleases,
            .getAppInfo
        ]

        // We can't automatically synthesize CaseIterable conformance, due to
        // this enum's cases having associated values, so we're providing the
        // list manually. We hard code the list then iterate through it to
        // ensure compiler errors here if new cases are added. Performance
        // doesn't matter since this only runs once, and only when
        // running tests.

        var finalCases = [ApiEndpoint]()
        for testCase in testCases {
            switch testCase {
            case .getUserInfo, .getCards, .getFeedbackForm,
                 .postSubmitFeedbackForm, .postBulkAnswerQuestions,
                 .postBulkSubmitSessions, .postPushTokens,
                 .getRoadmap, .getPaginateTickets, .postVoteForTicket,
                 .deleteVoteForTicket, .getRelease, .getPaginateReleases,
                 .getAppInfo, .postLogin, .postLogout,
                 .postUpdateAvatar, .deleteUser:

                finalCases.append(testCase)
            }
        }

        return finalCases
    }()
}
